//
//  AssistiveChatHost.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/21/23.
//

import UIKit
import NaturalLanguage
import CoreLocation

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
    
    public enum Intent {
        case Unsupported
        case SaveDefault
        case SearchDefault
        case RecallDefault
        case TellDefault
        case OpenDefault
        case SearchQuery
        case TellQuery
        case SavePlace
        case SearchPlace
        case RecallPlace
        case TellPlace
        case PlaceDetailsDirections
        case PlaceDetailsPhotos
        case PlaceDetailsTips
        case PlaceDetailsInstagram
        case PlaceDetailsOpenHours
        case PlaceDetailsBusyHours
        case PlaceDetailsPopularity
        case PlaceDetailsCost
        case PlaceDetailsMenu
        case PlaceDetailsPhone
        case ShareResult
    }
    
    weak private var delegate:AssistiveChatHostMessagesDelegate?
    private var languageDelegate:LanguageGeneratorDelegate = LanguageGenerator()
    private var placeSearchSession = PlaceSearchSession()
    @Published public var queryIntentParameters = AssistiveChatHostQueryParameters()
    public init(delegate:AssistiveChatHostMessagesDelegate? = nil) {
        self.delegate = delegate
    }
    
    public func didTap(chatResult: ChatResult) {
        print("Did tap result:\(chatResult.title) for place:")
        delegate?.didTap(chatResult: chatResult, selectedPlaceSearchResponse: chatResult.placeResponse, selectedPlaceSearchDetails:chatResult.placeDetailsResponse, intentHistory: queryIntentParameters.queryIntents)
    }
    
    
    public func determineIntent(for caption:String, parameters:[String:Any]?, chatResult:ChatResult? = nil, lastIntent:AssistiveChatHostIntent?)->Intent
    {
        let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass])
        tagger.string = caption

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
        var foundName:Bool = false

        tagger.enumerateTags(in: caption.startIndex..<caption.endIndex, unit: .word, scheme: .nameTypeOrLexicalClass, options: options) { tag, tokenRange in
            // Get the most likely tag, and print it if it's a named entity.
            if let tag = tag, tags.contains(tag) {
                print("\(caption[tokenRange]): \(tag.rawValue)")
                foundName = true
            } else {
                print("\(caption[tokenRange]): \(tag?.rawValue ?? "")")
            }
                
            // Get multiple possible tags with their associated confidence scores.
            let (hypotheses, _) = tagger.tagHypotheses(at: tokenRange.lowerBound, unit: .word, scheme: .nameTypeOrLexicalClass, maximumCount: 1)
            print(hypotheses)
                
           return true
        }
        
        switch caption{
        case "I like a place":
            return .SaveDefault
        case "Where can I find":
            return .SearchDefault
        case "What did I like":
            return .RecallDefault
        case "Tell me about":
            return .TellDefault
        case "Ask a different question":
            return .OpenDefault
        default:
            if caption.starts(with: "I like a place") {
                return .SavePlace
            } else if caption.starts(with: "Where can I") {
                if caption.hasSuffix("a place or a thing?") {
                    return .SearchDefault
                }
                if chatResult?.placeResponse != nil || foundName {
                    return .SearchPlace
                }
                return .SearchQuery
            } else if caption.starts(with:"What did I like") {
                return .RecallPlace
            } else if caption.starts(with:"Tell me about") {
                if chatResult?.placeResponse != nil || foundName {
                    
                    if let placeResponse = chatResult?.placeResponse, caption.contains(placeResponse.name) {
                        return .TellPlace
                    } else if foundName {
                        return .TellPlace
                    }
                }
                return .TellQuery
            } else if caption.starts(with: "How do I get to") {
                return .PlaceDetailsDirections
            } else if caption.starts(with: "Show me the photos for") {
                return .PlaceDetailsPhotos
            } else if caption.starts(with: "What do people say about") {
                return .PlaceDetailsTips
            } else if caption.starts(with: "What is") {
                if caption.hasSuffix("Instagram account?") {
                    return .PlaceDetailsInstagram
                } else if caption.hasSuffix("phone number?") {
                    return .PlaceDetailsPhone
                }
            } else if caption.starts(with: "When is it busy at") {
                return .PlaceDetailsBusyHours
            } else if caption.starts(with: "How popular is") {
                return .PlaceDetailsPopularity
            } else if caption.starts(with: "How much does") {
                return .PlaceDetailsCost
            } else if caption.starts(with: "What does") {
                return .PlaceDetailsMenu
            } else if caption.starts(with: "When is") && caption.hasSuffix("open?") {
                return .PlaceDetailsOpenHours
            }
            
            if let chatResult = chatResult, let placeResponse = chatResult.placeResponse, let detailsResponse = chatResult.placeDetailsResponse {
                switch chatResult.title {
                case placeResponse.address, placeResponse.formattedAddress, placeResponse.addressExtended:
                    return .ShareResult
                default:
                    if let tel = detailsResponse.tel, chatResult.title == tel {
                        return .ShareResult
                    }
                    if let website = detailsResponse.website, chatResult.title == website {
                        return .ShareResult
                    }
                    if let description = detailsResponse.description, chatResult.title == description {
                        return .ShareResult
                    }
                    if let hours = detailsResponse.hours, chatResult.title == hours {
                        return .ShareResult
                    }
                    if let price = detailsResponse.price, chatResult.title == "\(price)" {
                        return .ShareResult
                    }
                }
            }
            
            if let chatResult = chatResult, let _ = chatResult.placeResponse, let tipsResponses = chatResult.placeDetailsResponse?.tipsResponses {
                for response in tipsResponses {
                    if chatResult.title == response.text {
                        return .ShareResult
                    }
                }
            }
            return .Unsupported
        }
    }
    
    public func refreshParameters(for query:String, intent:AssistiveChatHostIntent) async throws {
        switch intent.intent {
        case .TellQuery, .TellPlace, .SearchPlace:
            queryIntentParameters.queryParameters = try await defaultParameters(for: query)
        case .SearchQuery:
            var defaultParameters = try await defaultParameters(for: query)
            if let embeddedParameters = defaultParameters?["parameters"] as? [String:Any] {
                var revisedParameters = embeddedParameters
                revisedParameters["sort"] = "rating"
                revisedParameters["radius"] = 500
                revisedParameters["limit"] = 5
                revisedParameters["open_now"] = true
                defaultParameters?["parameters"] = revisedParameters
            }
            queryIntentParameters.queryParameters = defaultParameters
        default:
            queryIntentParameters.queryParameters = nil
            break
        }
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
            print(error.localizedDescription)
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
        delegate?.didUpdateQuery(with:queryIntentParameters, nearLocation: nearLocation)
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
