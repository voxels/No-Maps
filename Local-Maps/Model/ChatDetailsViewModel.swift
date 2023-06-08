//
//  ChatDetailsViewModel.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/4/23.
//

import Foundation
import CoreLocation

public enum ChatDetailsViewModelError : Error {
    case NoIntentFound
}

public protocol ChatDetailsViewModelDelegate : AnyObject {
    func modelDidUpdate()
}

public class ChatDetailsViewModel {
    public var currentIntent:AssistiveChatHostIntent
    public var queryParameters:AssistiveChatHostQueryParameters
    public var responseString:String?
    public var placeSearchResponses:[PlaceSearchResponse] = [PlaceSearchResponse]()
    public var placeDetailsResponses:[PlaceDetailsResponse] = [PlaceDetailsResponse]()
    public weak var delegate:ChatDetailsViewModelDelegate?
    internal var maxChatResults = 8
    
    private var placeSearchSession = PlaceSearchSession()
    
    public init(queryParameters:AssistiveChatHostQueryParameters, intent:AssistiveChatHostIntent, delegate:ChatDetailsViewModelDelegate? ) {
        self.currentIntent = intent
        self.queryParameters = queryParameters
        self.delegate = delegate
    }
    
    public func updateModel(parameters:AssistiveChatHostQueryParameters, responseString:String? = nil, placeSearchResponses:[PlaceSearchResponse] = [PlaceSearchResponse](), nearLocation:CLLocation) async throws {
        guard let lastIntent = parameters.queryIntents.last else {
            throw ChatDetailsViewModelError.NoIntentFound
        }
        self.currentIntent = lastIntent
        self.queryParameters = parameters
        self.responseString = responseString
        self.placeSearchResponses = placeSearchResponses

        placeDetailsResponses.removeAll()

        switch lastIntent.intent {
        case .SearchQuery:            
            try await fetchDetails(for: self.placeSearchResponses)
        default:
            break
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.modelDidUpdate()
        }
    }
    
    internal func fetchDetails(for responses:[PlaceSearchResponse]) async throws {
        placeDetailsResponses = try await withThrowingTaskGroup(of: PlaceDetailsResponse.self, returning: [PlaceDetailsResponse].self) { [weak self] taskGroup in
            guard let strongSelf = self else {
                return [PlaceDetailsResponse]()
            }
            for index in 0..<(min(responses.count, strongSelf.maxChatResults)) {
                taskGroup.addTask {
                    let response = responses[index]
                    print("Fetching photos for \(response.name)")
                    let rawPhotosResponse = try await strongSelf.placeSearchSession.photos(for: response.fsqID)
                    let placePhotosResponses = try PlaceResponseFormatter.placePhotoResponses(with: rawPhotosResponse, for:response.fsqID)
                    print("Fetching tips for \(response.name)")
                    let rawTipsResponse = try await strongSelf.placeSearchSession.tips(for: response.fsqID)
                    let placeTipsResponses = try PlaceResponseFormatter.placeTipsResponses(with: rawTipsResponse, for:response.fsqID)
                    
                    let request = PlaceDetailsRequest(fsqID: response.fsqID, description: true, tel: true, fax: false, email: false, website: true, socialMedia: true, verified: false, hours: true, hoursPopular: true, rating: true, stats: false, popularity: true, price: true, menu: true, tastes: true, features: false)
                    print("Fetching details for \(response.name)")
                    let rawDetailsResponse = try await strongSelf.placeSearchSession.details(for: request)
                    print(rawDetailsResponse)
                    let detailsResponse = try PlaceResponseFormatter.placeDetailsResponse(with: rawDetailsResponse, for: response, placePhotosResponses: placePhotosResponses, placeTipsResponses: placeTipsResponses)
                    return detailsResponse
                }
            }
            var allResponses = [PlaceDetailsResponse]()
            for try await value in taskGroup {
                allResponses.append(value)
            }
            return allResponses
        }
    }
}
