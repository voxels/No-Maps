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
            self.placeSearchResponses = placeSearchResponses.sorted(by: { firstLocation, checkLocation in
                let firstLocationCoordinate = CLLocation(latitude: firstLocation.latitude, longitude: firstLocation.longitude)
                let checkLocationCoordinate = CLLocation(latitude: checkLocation.latitude, longitude: checkLocation.longitude)
                
                return firstLocationCoordinate.distance(from: nearLocation) < checkLocationCoordinate.distance(from: nearLocation)
            })
            
            try await fetchDetails(for: self.placeSearchResponses)
        default:
            break
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.modelDidUpdate()
        }
    }
    
    internal func fetchDetails(for responses:[PlaceSearchResponse]) async throws {
        for response in responses {
            
            print("Fetching photos for \(response.name)")
            do {
                let rawPhotosResponse = try await placeSearchSession.photos(for: response.fsqID)
                let placePhotosResponses = try PlaceResponseFormatter.placePhotoResponses(with: rawPhotosResponse, for:response.fsqID)
                print("Fetching tips for \(response.name)")
                let rawTipsResponse = try await placeSearchSession.tips(for: response.fsqID)
                let placeTipsResponses = try PlaceResponseFormatter.placeTipsResponses(with: rawTipsResponse, for:response.fsqID)
                
                let request = PlaceDetailsRequest(fsqID: response.fsqID, description: true, tel: true, fax: false, email: false, website: true, socialMedia: true, verified: false, hours: true, hoursPopular: true, rating: true, stats: false, popularity: true, price: true, menu: true, tastes: true, features: false)
                print("Fetching details for \(response.name)")
                let rawDetailsResponse = try await placeSearchSession.details(for: request)
                print(rawDetailsResponse)
                let detailsResponse = try PlaceResponseFormatter.placeDetailsResponse(with: rawDetailsResponse, for: response, placePhotosResponses: placePhotosResponses, placeTipsResponses: placeTipsResponses)
                placeDetailsResponses.append(detailsResponse)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
