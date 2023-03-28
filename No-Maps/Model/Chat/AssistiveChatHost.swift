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
    func didUpdateQuery(with parameters:AssistiveChatHostQueryParameters)
    func send(message:String)
}

open class AssistiveChatHost : ChatHostingViewControllerDelegate, ObservableObject {
    
    public enum Intent {
        case Save
        case Search
        case Recall
        case Tell
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
            return .Save
        case "Where can I find":
            return .Search
        case "What did I like":
            return .Recall
        default:
            if caption.starts(with: "I like a place") {
                return .Save
            } else if caption.starts(with: "Where can I find") {
                return .Search
            } else if caption.starts(with:"What did I like") {
                return .Recall
            }
            
            return .Tell
        }
    }
    
    public func appendIntentParameters(intent:AssistiveChatHostIntent) {
        queryIntentParameters.queryIntents.append(intent)
        delegate?.didUpdateQuery(with:queryIntentParameters)
    }
    
    public func resetIntentParameters() {
        queryIntentParameters.queryIntents = [AssistiveChatHostIntent]()
    }
}
