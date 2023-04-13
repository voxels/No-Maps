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
    public var currentIntent:AssistiveChatHostIntent
    public var queryParameters:AssistiveChatHostQueryParameters
    public var responseString:String?
    public var placeDetailsResponses:[PlaceDetailsResponse] = [PlaceDetailsResponse]()
    public weak var delegate:ChatDetailsViewModelDelegate?
    public init(queryParameters:AssistiveChatHostQueryParameters, intent:AssistiveChatHostIntent, delegate:ChatDetailsViewModelDelegate? ) {
        self.currentIntent = intent
        self.queryParameters = queryParameters
        self.delegate = delegate
    }
    
    public func updateModel(parameters:AssistiveChatHostQueryParameters, responseString:String? = nil, placeDetailsResponses:[PlaceDetailsResponse] = [PlaceDetailsResponse]() ) throws {
        guard let lastIntent = parameters.queryIntents.last else {
            throw ChatDetailsViewModelError.NoIntentFound
        }
        self.currentIntent = lastIntent
        self.queryParameters = parameters
        self.responseString = responseString
        self.placeDetailsResponses = placeDetailsResponses
        delegate?.modelDidUpdate()
    }
}
