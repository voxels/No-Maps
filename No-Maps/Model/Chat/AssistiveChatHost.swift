//
//  AssistiveChatHost.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/21/23.
//

import Foundation

public struct AssistiveChatHostIntent : Equatable {
    public let uuid = UUID()
    public let caption:String
    public let intent:AssistiveChatHost.Intent
}

public protocol AssistiveChatHostMessagesDelegate : AnyObject {
    func addReceivedMessage(caption:String, parameters:AssistiveChatHostQueryParameters, isLocalParticipant:Bool)
    func didUpdateQuery(with parameters:AssistiveChatHostQueryParameters)
    func send(message:String)
}

open class AssistiveChatHost : ChatHostingViewControllerDelegate, ObservableObject {
    
    public enum Intent {
        case Unsupported
        case SaveDefault
        case SearchDefault
        case RecallDefault
        case TellDefault
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
    }
    
    weak private var delegate:AssistiveChatHostMessagesDelegate?
    @Published public var queryIntentParameters = AssistiveChatHostQueryParameters()
    public init(delegate:AssistiveChatHostMessagesDelegate? = nil) {
        self.delegate = delegate
    }
    
    public func didTap(question: String) {
        delegate?.send(message: question)
    }
    
    public func determineIntent(for caption:String)->Intent {
        switch caption{
        case "I like a place":
            return .SaveDefault
        case "Where can I find":
            return .SearchDefault
        case "What did I like":
            return .RecallDefault
        case "Tell me about":
            return .TellDefault
        default:
            if caption.starts(with: "I like a place") {
                return .SavePlace
            } else if caption.starts(with: "Where can I find") {
                if caption.hasSuffix("a different place?") {
                    return .SearchDefault
                }
                return .SearchPlace
            } else if caption.starts(with:"What did I like") {
                return .RecallPlace
            } else if caption.starts(with:"Tell me about") {
                return .TellPlace
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
            
            return .Unsupported
        }
    }
    
    public func appendIntentParameters(intent:AssistiveChatHostIntent) {
        queryIntentParameters.queryIntents.append(intent)
        delegate?.didUpdateQuery(with:queryIntentParameters)
    }
    
    public func resetIntentParameters() {
        queryIntentParameters.queryIntents = [AssistiveChatHostIntent]()
    }
    
    public func receiveMessage(caption:String, isLocalParticipant:Bool ) {
        delegate?.addReceivedMessage(caption: caption, parameters: queryIntentParameters, isLocalParticipant: isLocalParticipant)
    }
}
