//
//  ChatDetailsViewModel.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/4/23.
//

import Foundation

public enum ChatDetailsViewModelError : Error {
    case NoIntentFound
}

public protocol ChatDetailsViewModelDelegate : AnyObject {
    func modelDidUpdate()
}

public class ChatDetailsViewModel {
    public var queryParameters:AssistiveChatHostQueryParameters
    public var responseString:String?
    public weak var delegate:ChatDetailsViewModelDelegate?
    public init(queryParameters:AssistiveChatHostQueryParameters, delegate:ChatDetailsViewModelDelegate? ) {
        self.queryParameters = queryParameters
        self.delegate = delegate
    }
    
    public func updateModel(parameters:AssistiveChatHostQueryParameters, responseString:String? = nil ) throws {
        guard let intent = parameters.queryIntents.last?.intent else {
            throw ChatDetailsViewModelError.NoIntentFound
        }
        
        self.queryParameters = parameters
        self.responseString = responseString
        
        switch intent {
        case .Unsupported:
            break
        case .SaveDefault, .SearchDefault, .RecallDefault, .TellDefault:
            // Open the drawer and search for a new place
            break
        case .OpenDefault:
            // Open the drawer and search for something else
            break
        case .SearchPlace:
            // Open Apple Maps
            break
        case .RecallPlace:
            // Open drawer and show past places
            break
        case .TellPlace:
            // Open drawer and show description
            break
        case .SavePlace:
            // Save the place and confirm place has been saved
            break
        case .PlaceDetailsDirections:
            // Open Apple Maps Directions
            break
        case .PlaceDetailsPhotos:
            // open drawer and show photos
            break
        case .PlaceDetailsTips:
            // open drawer and show tips
            break
        case .PlaceDetailsInstagram:
            break
        case .PlaceDetailsOpenHours:
            break
        case .PlaceDetailsBusyHours:
            break
        case .PlaceDetailsPopularity:
            break
        case .PlaceDetailsCost:
            break
        case .PlaceDetailsMenu:
            break
        case .PlaceDetailsPhone:
            break
        case .ShareResult:
            break
        }
        
        delegate?.modelDidUpdate()
    }
}
