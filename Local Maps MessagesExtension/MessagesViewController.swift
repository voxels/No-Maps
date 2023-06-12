//
//  MessagesViewController.swift
//  No Maps MessagesExtension
//
//  Created by Michael A Edgcumbe on 3/15/23.
//

import UIKit
import Messages
import SwiftUI
import CoreLocation

public enum MessagesViewControllerError : Error {
    case NoConversationRecorded
    case ShowingDetailsWithNoIntent
    case ChatDetailsViewControllerNotFound
}

public protocol ChatHostingViewControllerDelegate : AnyObject {
    func didTap(chatResult:ChatResult)
}

open class MessagesViewController: MSMessagesAppViewController {
    var chatDetailsContainerView:UIView?
    var chatDetailsViewController:ChatDetailsViewController?
    var chatResultView:UIHostingController<ChatResultView>?
    private var chatHost = AssistiveChatHost()
    private var session = MSSession()
    private var chatModel = ChatResultViewModel()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        chatHost = AssistiveChatHost(delegate:self)
        let resultView = ChatResultView(chatHost: self.chatHost, model: self.chatModel)
        chatResultView = UIHostingController(rootView: resultView)
        addChild(chatResultView!)
        view.addSubview(chatResultView!.view)
        
        chatResultView?.view.translatesAutoresizingMaskIntoConstraints = false
        chatResultView?.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        chatResultView?.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        chatResultView?.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.chatModel.delegate = self
        
        chatDetailsContainerView = UIView(frame: .zero)
        chatDetailsContainerView?.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(chatDetailsContainerView!, belowSubview: chatResultView!.view)
        chatDetailsContainerView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        chatDetailsContainerView?.bottomAnchor.constraint(equalTo: chatResultView!.view.topAnchor).isActive = true
        chatDetailsContainerView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        chatDetailsContainerView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Conversation Handling
    
    open override func willBecomeActive(with conversation: MSConversation) {
        
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        print("will become active with selected message:\(String(describing: conversation.selectedMessage?.summaryText))")
    }
    
    
    open override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    open override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
        if message.senderParticipantIdentifier == conversation.localParticipantIdentifier {
            print("Did receive message from device: \(String(describing: message.summaryText))")
            if let caption = message.summaryText {
                _ = Task.init {
                    do {
                        if let location = chatModel.locationProvider.currentLocation() {
                            try await self.chatHost.receiveMessage(caption: caption, isLocalParticipant: true, nearLocation: location)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        } else {
            print("Did receive message from chat: \(String(describing: message.summaryText))")
            if let caption = message.summaryText {
                _ = Task.init {
                    do {
                        if let location = chatModel.locationProvider.currentLocation() {
                            try await self.chatHost.receiveMessage(caption: caption, isLocalParticipant: true, nearLocation: location)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    open override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        print("did send message")
        // Called when the user taps the send button.
        if message.senderParticipantIdentifier == conversation.localParticipantIdentifier {
            print("Did send message from device: \(String(describing: message.summaryText))")
        } else {
            print("Did send message from chat: \(String(describing: message.summaryText))")
        }
    }
    
    open override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
        if let location = chatModel.locationProvider.currentLocation() {
            chatModel.refreshModel(queryIntents:[AssistiveChatHostIntent](),parameters: self.chatHost.queryIntentParameters, nearLocation: location)
        }

    }
    
    open override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
        print("Will transition to \(presentationStyle)")
    }
    
    open override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}

public extension MessagesViewController {
    func add(caption:String, subcaption:String? = nil, image:UIImage? = nil, mediaFileURL:URL? = nil, imageTitle:String? = nil, imageSubtitle:String? = nil, trailingCaption:String? = nil, trailingSubcaption:String? = nil,to conversation:MSConversation?) throws {
        guard let conversation = conversation else {
            print("No conversation recorded")
            throw MessagesViewControllerError.NoConversationRecorded
        }
        
        print("Adding caption:\(caption) to conversation for participant:\(conversation.localParticipantIdentifier)")
        
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        layout.caption = caption
        if let subcaption = subcaption {
            layout.subcaption = subcaption
        }
        if let image = image {
            layout.image = image
        }
        if let mediaFileURL = mediaFileURL {
            layout.mediaFileURL = mediaFileURL
        }
        if let imageTitle = imageTitle {
            layout.imageTitle = imageTitle
        }
        if let imageSubtitle = imageSubtitle {
            layout.imageSubtitle = imageSubtitle
        }
        if let trailingCaption = trailingCaption {
            layout.trailingCaption = trailingCaption
        }
        if let trailingSubcaption = trailingSubcaption {
            layout.trailingSubcaption = trailingSubcaption
        }
        message.layout = layout
        message.summaryText = caption
    
        conversation.insert(message) { error in
            if let e = error {
                print(e.localizedDescription)
                return
            }
        }
    }
}

extension MessagesViewController {
    public func showDetailsViewController(with queryParameters:AssistiveChatHostQueryParameters, responseString:String, nearLocation:CLLocation) throws {
        guard let _ = queryParameters.queryIntents.last?.intent else {
            throw MessagesViewControllerError.ShowingDetailsWithNoIntent
        }
        
        if chatDetailsViewController == nil {
            chatDetailsViewController = ChatDetailsViewController(parameters: queryParameters)
            chatDetailsViewController?.delegate = self
            chatDetailsContainerView?.addSubview(chatDetailsViewController!.view)
            addChild(chatDetailsViewController!)
            chatDetailsViewController?.view.translatesAutoresizingMaskIntoConstraints = false
            chatDetailsViewController?.view.leftAnchor.constraint(equalTo: chatDetailsContainerView!.leftAnchor).isActive = true
            chatDetailsViewController?.view.rightAnchor.constraint(equalTo: chatDetailsContainerView!.rightAnchor).isActive = true
            chatDetailsViewController?.view.topAnchor.constraint(equalTo: chatDetailsContainerView!.topAnchor).isActive = true
            chatDetailsViewController?.view.bottomAnchor.constraint(equalTo: chatDetailsContainerView!.bottomAnchor).isActive = true

            chatDetailsViewController?.didMove(toParent: self)
            chatDetailsViewController?.update(parameters: queryParameters, responseString: responseString, placeSearchResponses:queryParameters.queryIntents.last!.placeSearchResponses, nearLocation: nearLocation)
        } else {
            chatDetailsViewController?.update(parameters: queryParameters, responseString: responseString, placeSearchResponses:queryParameters.queryIntents.last!.placeSearchResponses, nearLocation: nearLocation)
        }
        
        guard chatDetailsViewController != nil else {
            throw MessagesViewControllerError.ChatDetailsViewControllerNotFound
        }
        
        requestPresentationStyle(.expanded)
    }
}

extension MessagesViewController {
    @objc public func modelDidUpdate(nearLocation:CLLocation){
        if let lastIntent = chatModel.lastIntent {
            switch lastIntent.intent {
            case .Unsupported:
                break
            case .SaveDefault, .RecallDefault:
                // Open the drawer and search for a new place
                break
            case .SearchDefault, .TellDefault, .OpenDefault:
                let _ = Task.init {
                        let description = lastIntent.caption
                        DispatchQueue.main.async { [unowned self] in
                            do {
                                try self.showDetailsViewController(with: self.chatHost.queryIntentParameters, responseString: description, nearLocation: nearLocation)
                            } catch{
                                print(error.localizedDescription)
                            }
                        }
                }
                
            case .SearchQuery:
                let _ = Task.init {
                    do {
                        let description = try await self.chatHost.searchQueryDescription(nearLocation: nearLocation)
                        DispatchQueue.main.async { [unowned self] in
                            do {
                                try self.showDetailsViewController(with: self.chatHost.queryIntentParameters, responseString: description, nearLocation: nearLocation)
                            } catch{
                                print(error.localizedDescription)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            case .SearchPlace:
                // Open Apple Maps
                if let placeResponse = lastIntent.selectedPlaceSearchResponse, let details = lastIntent.selectedPlaceSearchDetails {
                    let _ = Task.init {
                        do {
                            let description = try await self.chatHost.placeDescription(searchResponse: placeResponse, detailsResponse: details)
                            DispatchQueue.main.async { [unowned self] in
                                do {
                                    try self.showDetailsViewController(with: self.chatHost.queryIntentParameters, responseString: description, nearLocation: nearLocation)
                                } catch{
                                    print(error.localizedDescription)
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            case .RecallPlace:
                // Open drawer and show past places
                break
            case .TellPlace, .TellQuery:
                // Open drawer and show description
                if let placeResponse = lastIntent.selectedPlaceSearchResponse, let details = lastIntent.selectedPlaceSearchDetails {
                    let _ = Task.init {
                        do {
                            let description = try await self.chatHost.placeDescription(searchResponse: placeResponse, detailsResponse: details)
                            DispatchQueue.main.async { [unowned self] in
                                do {
                                    try self.showDetailsViewController(with: self.chatHost.queryIntentParameters, responseString: description, nearLocation: nearLocation)
                                } catch{
                                    print(error.localizedDescription)
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                } else {
                    let _ = Task.init {
                            let description = lastIntent.caption
                            DispatchQueue.main.async { [unowned self] in
                                do {
                                    try self.showDetailsViewController(with: self.chatHost.queryIntentParameters, responseString: description, nearLocation: nearLocation)
                                } catch{
                                    print(error.localizedDescription)
                                }
                            }
                    }
                }
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
                if lastIntent.selectedPlaceSearchDetails?.socialMedia != nil {
                    composeIntentMessageAndSend(intent: lastIntent)
                } else {
                    // throw error
                }
            case .PlaceDetailsOpenHours:
                if lastIntent.selectedPlaceSearchDetails?.hours != nil {
                    composeIntentMessageAndSend(intent: lastIntent)
                } else {
                    // throw error
                }
            case .PlaceDetailsBusyHours:
                if lastIntent.selectedPlaceSearchDetails?.hoursPopular != nil {
                    composeIntentMessageAndSend(intent: lastIntent)
                } else {
                    // throw error
                }
            case .PlaceDetailsPopularity:
                if let pop = lastIntent.selectedPlaceSearchDetails?.popularity, pop > 0 {
                    composeIntentMessageAndSend(intent: lastIntent)
                } else {
                    // throw error
                }
            case .PlaceDetailsCost:
                if lastIntent.selectedPlaceSearchDetails?.price != nil {
                    composeIntentMessageAndSend(intent: lastIntent)
                } else {
                    // throw error
                }
            case .PlaceDetailsMenu:
                if lastIntent.selectedPlaceSearchDetails?.menu != nil {
                    composeIntentMessageAndSend(intent: lastIntent)
                } else {
                    // throw error
                }
            case .PlaceDetailsPhone:
                if lastIntent.selectedPlaceSearchDetails?.tel != nil {
                    composeIntentMessageAndSend(intent: lastIntent)
                } else {
                    // throw error
                }
                
            case .ShareResult:
                if lastIntent.selectedPlaceSearchResponse != nil {
                    composeIntentMessageAndSend(intent: lastIntent)
                } else {
                    
                }
            }
        } else {
            let _ = Task.init {
                    let description = ""
                    DispatchQueue.main.async { [unowned self] in
                        do {
                            try self.showDetailsViewController(with: self.chatHost.queryIntentParameters, responseString: description, nearLocation: nearLocation)
                        } catch{
                            print(error.localizedDescription)
                        }
                    }
            }
        }
    }
}


extension MessagesViewController : ChatDetailsViewControllerDelegate {
    public func detailsViewTargetLocation() -> CLLocation {
        return chatModel.locationProvider.currentLocation()!
    }
    
    public func didTap(textResponse: String) {
        
    }
    
    public func didRequestSearch(for query: String) {
        let _ = Task.init {
            let newIntent = AssistiveChatHostIntent(caption: query, intent: chatHost.determineIntent(for: query, parameters: nil, lastIntent: chatModel.lastIntent), selectedPlaceSearchResponse:nil, selectedPlaceSearchDetails:nil, placeSearchResponses:[PlaceSearchResponse]())
            try await self.chatHost.refreshParameters(for: query, intent:newIntent)
            let checkIntentWithParameters = chatHost.determineIntent(for: query, parameters: chatHost.queryIntentParameters.queryParameters, lastIntent: newIntent)
            if newIntent.intent == checkIntentWithParameters {
                chatHost.appendIntentParameters(intent: newIntent)
            } else {
                let revisedIntent = AssistiveChatHostIntent(caption: query, intent: checkIntentWithParameters, selectedPlaceSearchResponse: nil, selectedPlaceSearchDetails: nil, placeSearchResponses: [PlaceSearchResponse]())
                try await self.chatHost.refreshParameters(for: query, intent:revisedIntent)
                chatHost.appendIntentParameters(intent: revisedIntent)
            }
            if let location = chatModel.locationProvider.currentLocation() {
                try await self.chatHost.receiveMessage(caption: query, isLocalParticipant: true, nearLocation: location)
            }
        }
    }
}


extension MessagesViewController : AssistiveChatHostMessagesDelegate {
    public func didTap(chatResult: ChatResult, selectedPlaceSearchResponse:PlaceSearchResponse?, selectedPlaceSearchDetails:PlaceDetailsResponse?, intentHistory:[AssistiveChatHostIntent]? = nil) {
        let _ = Task.init {
            let caption = chatResult.title
            if let lastIntent = intentHistory?.last?.intent {
                switch lastIntent{
                case .TellDefault, .SaveDefault, .RecallDefault, .SearchDefault:
                    //self.chatHost.resetIntentParameters()
                    break
                default:
                    break
                }
            }
            
            let newIntent = AssistiveChatHostIntent(caption: caption, intent: chatHost.determineIntent(for: caption, parameters: nil, chatResult: chatResult, lastIntent: intentHistory?.last), selectedPlaceSearchResponse: selectedPlaceSearchResponse, selectedPlaceSearchDetails: selectedPlaceSearchDetails, placeSearchResponses: [PlaceSearchResponse]())
            try await self.chatHost.refreshParameters(for: caption, intent:newIntent)
            let checkIntentWithParameters = chatHost.determineIntent(for: caption, parameters: chatHost.queryIntentParameters.queryParameters, chatResult: chatResult, lastIntent: newIntent)
            if checkIntentWithParameters == newIntent.intent {
                chatHost.appendIntentParameters(intent: newIntent)
            } else {
                let revisedIntent = AssistiveChatHostIntent(caption: caption, intent: checkIntentWithParameters, selectedPlaceSearchResponse: nil, selectedPlaceSearchDetails: nil, placeSearchResponses: [PlaceSearchResponse]())
                try await self.chatHost.refreshParameters(for: caption, intent:revisedIntent)
                chatHost.appendIntentParameters(intent: revisedIntent)
            }
            if let location = chatModel.locationProvider.currentLocation() {
                try await self.chatHost.receiveMessage(caption: caption, isLocalParticipant: true, nearLocation: location)
            }
        }
    }
    
    public func addReceivedMessage(caption: String, parameters: AssistiveChatHostQueryParameters, isLocalParticipant: Bool, nearLocation:CLLocation) async throws {
        try await chatModel.receiveMessage(caption: caption, parameters: parameters, isLocalParticipant: isLocalParticipant, nearLocation: nearLocation)
    }
    
    public func send(caption:String, subcaption:String? = nil, image:UIImage? = nil, mediaFileURL:URL? = nil, imageTitle:String? = nil, imageSubtitle:String? = nil, trailingCaption:String? = nil, trailingSubcaption:String? = nil) {
        print("Send message\(caption)")
        do {
            try add(caption: caption, subcaption: subcaption, image:image, mediaFileURL: mediaFileURL, imageTitle: imageTitle, imageSubtitle: imageSubtitle, trailingCaption: trailingCaption, trailingSubcaption: trailingSubcaption, to: activeConversation)
        } catch {
            print(error)
        }
    }
    
    public func didUpdateQuery(with parameters: AssistiveChatHostQueryParameters, nearLocation:CLLocation) {
        print("Did update query with parameters:")
        for intent in parameters.queryIntents {
            print(intent.intent)
            print(intent.caption)
        }
        
        print("Paramaters did update, requesting new chat model")
        chatModel.refreshModel(queryIntents: parameters.queryIntents, parameters: chatHost.queryIntentParameters, nearLocation: nearLocation )
        
        if let chatDetailsViewController = chatDetailsViewController, chatDetailsViewController.model.currentIntent != parameters.queryIntents.last {
            chatDetailsViewController.willUpdateModel()
        }
    }
    
    public func composeIntentMessageAndSend(intent:AssistiveChatHostIntent) {
        switch intent.intent {
        case .Unsupported:
            break
        case .SaveDefault, .SearchDefault, .RecallDefault, .TellDefault:
            // Search for a place
            break
        case .SearchQuery, .TellQuery:
            break
        case .OpenDefault:
            // Search for something else
            break
        case .SavePlace:
            break
        case .SearchPlace:
            break
        case .RecallPlace:
            break
        case .TellPlace:
            if let placeResponse = intent.selectedPlaceSearchResponse, let details = intent.selectedPlaceSearchDetails {
                var photoURL:URL?
                if let photoResponses = details.photoResponses, let firstPhoto = photoResponses.randomElement() {
                    photoURL = firstPhoto.photoUrl()
                }
                var image:UIImage?
                if let url = photoURL, let data = try? Data(contentsOf: url) {
                    image = UIImage(data: data)
                }
                let _ = Task.init {
                    do {
                        let description = try await self.chatHost.placeDescription(searchResponse: placeResponse, detailsResponse: details)
                        send(caption:description, subcaption:nil, image:image, mediaFileURL:nil, imageTitle:nil, imageSubtitle:nil, trailingCaption:nil, trailingSubcaption:nil)
                        
                    } catch {
                        print(error)
                    }
                }

            }
        case .PlaceDetailsDirections:
            break
        case .PlaceDetailsPhotos:
            break
        case .PlaceDetailsTips:
            break
        case .PlaceDetailsInstagram:
            break
        case .PlaceDetailsOpenHours:
            if let searchResponse = intent.selectedPlaceSearchResponse, let details = intent.selectedPlaceSearchDetails, let hours = details.hours {
                send(caption:hours, subcaption:"Open Now", image:nil, mediaFileURL:nil, imageTitle:nil, imageSubtitle:nil, trailingCaption:searchResponse.name, trailingSubcaption:nil)
            }
        case .PlaceDetailsBusyHours:
            // compose message and send
            break
        case .PlaceDetailsPopularity:
            if let searchResponse = intent.selectedPlaceSearchResponse, let details = intent.selectedPlaceSearchDetails, details.popularity > 0 {
                send(caption:"Popularity Score: \(details.popularity)}", subcaption:nil, image:nil, mediaFileURL:nil, imageTitle:nil, imageSubtitle:nil, trailingCaption:searchResponse.name, trailingSubcaption:nil)
            }
        case .PlaceDetailsCost:
            if let searchResponse = intent.selectedPlaceSearchResponse, let details = intent.selectedPlaceSearchDetails, let price = details.price {
                send(caption:"\(price)", subcaption:nil, image:nil, mediaFileURL:nil, imageTitle:nil, imageSubtitle:nil, trailingCaption:searchResponse.name, trailingSubcaption:nil)
            }
        case .PlaceDetailsMenu:
            // compose message and send
            break
        case .PlaceDetailsPhone:
            // compose message and send
            if let searchResponse = intent.selectedPlaceSearchResponse, let details = intent.selectedPlaceSearchDetails, let tel = details.tel {
                send(caption:tel, subcaption:nil, image:nil, mediaFileURL:nil, imageTitle:nil, imageSubtitle:nil, trailingCaption:searchResponse.name, trailingSubcaption:nil)
            }
        case .ShareResult:
            if let searchResponse = intent.selectedPlaceSearchResponse, let details = intent.selectedPlaceSearchDetails {
                var photoURL:URL?
                if let photoResponses = details.photoResponses, let firstPhoto = photoResponses.randomElement() {
                    photoURL = firstPhoto.photoUrl()
                }
                var image:UIImage?
                if let url = photoURL, let data = try? Data(contentsOf: url) {
                    image = UIImage(data: data)
                }
                send(caption:intent.caption ,subcaption:nil, image:image, mediaFileURL:nil, imageTitle:nil, imageSubtitle:nil, trailingCaption:searchResponse.name, trailingSubcaption:nil)
            }
        }
    }
}

extension MessagesViewController : ChatResultViewModelDelegate {
    public func didUpdateModel(for location: CLLocation?) {
        if let location = location {
            modelDidUpdate(nearLocation: location)
        }
    }
}
