//
//  AssistiveChatHost.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/21/23.
//

import UIKit
import NaturalLanguage
import CoreLocation
import CoreML

public struct AssistiveChatHostIntent : Equatable {
    public let uuid = UUID()
    public let caption:String
    public let intent:AssistiveChatHost.Intent
    public let selectedPlaceSearchResponse:PlaceSearchResponse?
    public let selectedPlaceSearchDetails:PlaceDetailsResponse?
    public let placeSearchResponses:[PlaceSearchResponse]
    
    public static func == (lhs: AssistiveChatHostIntent, rhs: AssistiveChatHostIntent) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

public protocol AssistiveChatHostMessagesDelegate : AnyObject {
    func didTap(chatResult:ChatResult, selectedPlaceSearchResponse:PlaceSearchResponse?, selectedPlaceSearchDetails:PlaceDetailsResponse?, intentHistory:[AssistiveChatHostIntent]?)
    func addReceivedMessage(caption:String, parameters:AssistiveChatHostQueryParameters, isLocalParticipant:Bool, nearLocation:CLLocation) async throws
    func didUpdateQuery(with parameters:AssistiveChatHostQueryParameters, nearLocation:CLLocation)
    func send(caption:String, subcaption:String?, image:UIImage?, mediaFileURL:URL?, imageTitle:String?, imageSubtitle:String?, trailingCaption:String?, trailingSubcaption:String?)
}

open class AssistiveChatHost : ChatHostingViewControllerDelegate, ObservableObject {
    
    public enum Intent : String {
        case Unsupported
        case SearchDefault
        case TellDefault
        case SearchQuery
        case TellPlace
        case ShareResult
        case PlaceDetails
    }
    
    weak private var delegate:AssistiveChatHostMessagesDelegate?
    private var languageDelegate:LanguageGeneratorDelegate = LanguageGenerator()
    private var placeSearchSession = PlaceSearchSession()
    @Published public var queryIntentParameters = AssistiveChatHostQueryParameters()
    private var categoryCodes:[String:String] = [String:String]()
    
    public init(delegate:AssistiveChatHostMessagesDelegate? = nil) {
        self.delegate = delegate

        _ = Task.init{
            do {
                try organizeCategoryCodeList()
            } catch {
                print(error)
            }
        }
    }
    
    internal func organizeCategoryCodeList() throws {
        if let path = Bundle.main.path(forResource: "integrated_category_taxonomy", ofType: "json")
        {
            let url = URL(filePath: path)
            let data = try Data(contentsOf: url)
            let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let dict = result as? NSDictionary {
                for key in dict.allKeys {
                    if let valueDict = dict[key] as? NSDictionary {
                        if let labelsDict = valueDict["labels"] as? NSDictionary, let englishLabel = labelsDict["en"] as? String, let keyString = key as? String {
                            categoryCodes[englishLabel] = keyString
                        }
                    }
                }
            }
        }
    }
    
    public func didTap(chatResult: ChatResult) {
        print("Did tap result:\(chatResult.title) for place:")
        delegate?.didTap(chatResult: chatResult, selectedPlaceSearchResponse: chatResult.placeResponse, selectedPlaceSearchDetails:chatResult.placeDetailsResponse, intentHistory: queryIntentParameters.queryIntents)
    }
    
    
    public func determineIntent(for caption:String) throws -> Intent
    {
        if caption == "Where can I find" {
            return .SearchDefault
        }
        
        if caption == "Tell me about" {
            return .TellDefault
        }
        
        let mlModel = try LocalMapsQueryClassifier(configuration: MLModelConfiguration()).model
        let predictor = try NLModel(mlModel: mlModel)
        if let label = predictor.predictedLabel(for: caption), let intent = Intent(rawValue: label) {
            print(label)
            return intent
        } else {
            return .Unsupported
        }
    }
    
    public func refreshParameters(for query:String, intent:AssistiveChatHostIntent) async throws {
        switch intent.intent {
        case .TellPlace:
            queryIntentParameters.queryParameters = try await defaultParameters(for: query)
        case .SearchQuery:
            var defaultParameters = try await defaultParameters(for: query)
            if let embeddedParameters = defaultParameters?["parameters"] as? [String:Any] {
                var revisedParameters = embeddedParameters
                revisedParameters["sort"] = "distance"
                revisedParameters["radius"] = 1000
                revisedParameters["limit"] = 8
                defaultParameters?["parameters"] = revisedParameters
            }
            queryIntentParameters.queryParameters = defaultParameters
        default:
            queryIntentParameters.queryParameters = nil
            break
        }
        
        print("Pre-NAICS code revision parameters")
        print(queryIntentParameters.queryParameters ?? "")
        if let parameters = queryIntentParameters.queryParameters?["parameters"] as? [String:Any], let categories = parameters["categories"] as? [NSDictionary]  {
            var revisedCategories = categories
            for index in 0..<categories.count {
                let category = categories[index]
                let revisedCategory:NSMutableDictionary = category.mutableCopy() as! NSMutableDictionary
                if let name = category["name"] as? String, let code = categoryCodes[name] {
                    revisedCategory["naics_code"] = code
                }
                revisedCategories[index] = revisedCategory
            }
            var revisedParameters = parameters
            revisedParameters["categories"] = revisedCategories
            queryIntentParameters.queryParameters?["parameters"] = revisedParameters
        }
        print("Revised NAICS code parameters")
        print(queryIntentParameters.queryParameters ?? "")
    }
    
    internal func defaultParameters(for query:String) async throws -> [String:Any]? {
        var rawParameters = try await languageDelegate.fetchSearchQueryParameters(with: query)

        rawParameters = rawParameters.trimmingCharacters(in: .whitespacesAndNewlines)
        rawParameters = rawParameters.replacingOccurrences(of: "\n", with: "")
        guard let data = rawParameters.data(using: .utf8) else {
            print("Raw parameters could not be encoded into json: \(rawParameters)")
            return nil
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            if let array = json as? [[String:Any]], let parameterDict = array.first {
                return parameterDict
            } else {
                print("Found non-dictionary object when attemting to refresh parameters:\(json)")
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    public func appendIntentParameters(intent:AssistiveChatHostIntent) {
        queryIntentParameters.queryIntents.append(intent)
    }
    
    public func resetIntentParameters() {
        queryIntentParameters.queryIntents = [AssistiveChatHostIntent]()
    }
    
    public func receiveMessage(caption:String, isLocalParticipant:Bool, nearLocation:CLLocation ) async throws {
        try await delegate?.addReceivedMessage(caption: caption, parameters: queryIntentParameters, isLocalParticipant: isLocalParticipant, nearLocation: nearLocation)
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didUpdateQuery(with:strongSelf.queryIntentParameters, nearLocation: nearLocation)
        }
    }
}

extension AssistiveChatHost {
    
    public func searchQueryDescription(nearLocation:CLLocation) async throws -> String {
        return try await languageDelegate.searchQueryDescription(nearLocation:nearLocation)
    }
    
    public func placeDescription(searchResponse:PlaceSearchResponse, detailsResponse:PlaceDetailsResponse) async throws ->String {
        return try await languageDelegate.placeDescription(searchResponse: searchResponse, detailsResponse: detailsResponse)
    }
    
    public func fetchSearchQueryParameters( with query:String) async throws -> String {
        return try await languageDelegate.fetchSearchQueryParameters(with: query)
    }
}
