//
//  ChatResultViewModel.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/20/23.
//

import SwiftUI
import NaturalLanguage

public class ChatResultViewModel : ObservableObject {
    private let placeSearchSession:PlaceSearchSession = PlaceSearchSession()
    private let locationProvider:LocationProvider = LocationProvider()
    private var localPlaceSearchResponses:[PlaceSearchResponse]?
    private let maxChatResults:Int = 30
    
    private var queryCaption:String?
    private var queryParametersHistory = [AssistiveChatHostQueryParameters]()
    
    public var lastIntent:AssistiveChatHostIntent? {
        return queryParametersHistory.last?.queryIntents.last
    }
    
    /*
     private static let modelDefaults:[ChatResult] = [
     ChatResult(title: "I like a place", backgroundColor: Color.green, backgroundImageURL: nil, placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil),
     ChatResult(title: "Where can I find", backgroundColor: Color.green, backgroundImageURL: nil,  placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil),
     ChatResult(title: "What did I like", backgroundColor: Color.green, backgroundImageURL: nil,  placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil),
     ChatResult(title: "Tell me about", backgroundColor: Color.green, backgroundImageURL: nil,  placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil),
     ChatResult(title: "Ask a different question", backgroundColor: Color.red, backgroundImageURL: nil, placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil)
     ]
     */
    
    private static let modelDefaults:[ChatResult] = [
        ChatResult(title: "Where can I find", backgroundColor: Color.green, backgroundImageURL: nil,  placeResponse: nil, placeDetailsResponse: nil),
        ChatResult(title: "Tell me about", backgroundColor: Color.green, backgroundImageURL: nil,  placeResponse: nil, placeDetailsResponse: nil),
    ]
    
    
    
    @Published public var results:[ChatResult] = ChatResultViewModel.modelDefaults
    
    public func authorizeLocationProvider() {
        locationProvider.authorize()
    }
    
    public func placeSearchResponses(for caption:String)->[PlaceSearchResponse] {
        var retval = [PlaceSearchResponse]()
        guard let localPlaceSearchResponses = localPlaceSearchResponses else {
            return retval
        }
        
        for response in localPlaceSearchResponses {
            if caption.contains(response.name.suffix(10)) || caption.contains(response.name) {
                retval.append(response)
            }
        }
        
        return retval
    }
    
    public func receiveMessage(caption: String, parameters: AssistiveChatHostQueryParameters, isLocalParticipant: Bool) async throws {
        queryCaption = caption
        queryParametersHistory.append(parameters)
        try await applyQuery(caption: queryCaption!, parameters: parameters, history: queryParametersHistory)
    }
    
    public func didTap(chatResult:ChatResult, parameters:AssistiveChatHostQueryParameters) {
        guard let intent = parameters.queryIntents.last else {
            return
        }
        
        switch intent.intent {
        case .Unsupported:
            break
        case .SaveDefault:
            break
        case .SearchDefault:
            break
        case .RecallDefault:
            break
        case .TellDefault:
            break
        case .OpenDefault:
            break
        case .SearchQuery:
            break
        case .TellQuery:
            break
        case .SavePlace:
            break
        case .SearchPlace:
            break
        case .RecallPlace:
            break
        case .TellPlace:
            break
        case .PlaceDetailsDirections:
            break
        case .PlaceDetailsPhotos:
            break
        case .PlaceDetailsTips:
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
    }
    
    public func
    applyQuery(caption:String, parameters:AssistiveChatHostQueryParameters, history:[AssistiveChatHostQueryParameters]) async throws {
        print("Applying query: \(caption)")
        print("With parameters:")
        for intent in parameters.queryIntents {
            print(intent.caption)
            print(intent.intent)
        }
        if let lastParameters = history.last, let lastIntent = lastParameters.queryIntents.last, lastIntent.selectedPlaceSearchResponse == nil {
            do {
                try await detailIntent(intent: lastIntent, parameters: parameters)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public func detailIntent(intent:AssistiveChatHostIntent, parameters:AssistiveChatHostQueryParameters) async throws {

        var checkResponses = [PlaceSearchResponse]()

        if intent.intent == .TellDefault || intent.intent == .SearchDefault {
            return
        }
        
        if let placeResponse = intent.selectedPlaceSearchResponse {
            checkResponses.append(placeResponse)
        } else {
            if let currentLocation = locationProvider.currentLocation() {
                let rawAutocompleteQuery = try await placeSearchSession.autocomplete(caption: intent.caption, parameters: parameters.queryParameters, currentLocation: currentLocation.coordinate)
                let autocompleteResponses = try PlaceResponseFormatter.autocompletePlaceSearchResponses(with: rawAutocompleteQuery)
                checkResponses.append(contentsOf:autocompleteResponses)
            }
            let request = placeSearchRequest(parameters: parameters)
            let rawQueryResponse = try await placeSearchSession.query(request:request)
            let placeSearchResponses = try PlaceResponseFormatter.placeSearchResponses(with: rawQueryResponse)
            checkResponses.append(contentsOf:placeSearchResponses)
        }
        
        let punctuationComponents = intent.caption.lowercased().components(separatedBy:.punctuationCharacters)
        var whitespaceComponents = [String]()
        for punctuationComponent in punctuationComponents {
            whitespaceComponents.append(contentsOf: punctuationComponent.components(separatedBy: .whitespacesAndNewlines))
        }
        
        var nearLocationStrings = (parameters.queryParameters?["parameters"] as? NSDictionary)?["near"] as? [String] ?? [String]()
        nearLocationStrings = nearLocationStrings.compactMap({ locationString in
            return locationString.lowercased()
        })
        var nearLocationStringComponents = [String]()
        for string in nearLocationStrings {
            nearLocationStringComponents.append(contentsOf: string.components(separatedBy: .whitespacesAndNewlines))
        }
        
        var checkCaption = intent.caption.lowercased()
        switch intent.intent {
        case .Unsupported:
            break
        case .SaveDefault, .SearchDefault, .RecallDefault, .TellDefault, .OpenDefault:
            break
        case .SearchQuery:
            if checkCaption.hasPrefix("where can i find") {
                checkCaption = String(checkCaption.dropFirst(16))
            }
        case .TellQuery:
            if checkCaption.hasPrefix("tell me about") {
                checkCaption = String(checkCaption.dropFirst(13))
            }
        case .SavePlace:
            break
        case .SearchPlace:
            break
        case .RecallPlace:
            break
        case .TellPlace:
            break
        case .PlaceDetailsDirections:
            break
        case .PlaceDetailsPhotos:
            break
        case .PlaceDetailsTips:
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
        
        
        let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass])
        tagger.string = checkCaption
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.preposition, .pronoun, .determiner]
        var excludeStrings:[String] = [String]()
        
        tagger.enumerateTags(in: checkCaption.startIndex..<checkCaption.endIndex, unit: .word, scheme: .nameTypeOrLexicalClass, options: options) { tag, tokenRange in
            // Get the most likely tag, and print it if it's a named entity.
            if let tag = tag, tags.contains(tag) {
                print("\(checkCaption[tokenRange]): \(tag.rawValue)")
                excludeStrings.append("\(checkCaption[tokenRange])".lowercased())
            }
            
            return true
        }
                
        for index in 0..<checkResponses.count {
            let response = checkResponses[index]
            var replaceIntents = [AssistiveChatHostIntent]()
            var foundNameComponents = 0

            let nameComponents = response.name.lowercased().components(separatedBy: .whitespacesAndNewlines)
            
            for component in nameComponents {
                
                if checkCaption.contains(component) && !excludeStrings.contains(component)  {
                    foundNameComponents += 1
                }
            }
            let foundMatch = foundNameComponents >= 2 || (nameComponents.count == 1 && foundNameComponents == 1)
            print(foundNameComponents)
            print(nameComponents.count)
            print(foundMatch)
            print(nameComponents)
            print(intent.caption.lowercased())
            print(nearLocationStringComponents)
            print(excludeStrings)
            
            if foundMatch {
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
                    
                    
                    for event in queryParametersHistory {
                        for index in 0..<event.queryIntents.count {
                            let intent = event.queryIntents[index]
                            if intent.selectedPlaceSearchResponse == nil || intent.selectedPlaceSearchDetails == nil, foundMatch {
                                    let newIntent = AssistiveChatHostIntent(caption: intent.caption, intent: intent.intent, selectedPlaceSearchResponse: response, selectedPlaceSearchDetails: detailsResponse, placeSearchResponses:checkResponses)
                                    replaceIntents.append(newIntent)
                            } else if intent.placeSearchResponses.count == 0, checkResponses.count > 0 {
                                let newIntent = AssistiveChatHostIntent(caption: intent.caption, intent: intent.intent, selectedPlaceSearchResponse: nil, selectedPlaceSearchDetails: nil, placeSearchResponses:checkResponses)
                                replaceIntents.append(newIntent)
                            }
                        }
                    }
                } catch {
                    print("Could not fetch details: catching error and continuing")
                    print(error.localizedDescription)
                    for event in queryParametersHistory {
                        for index in 0..<event.queryIntents.count {
                            let intent = event.queryIntents[index]
                            if intent.selectedPlaceSearchResponse == nil, foundMatch {
                                let newIntent = AssistiveChatHostIntent(caption: intent.caption, intent: intent.intent, selectedPlaceSearchResponse: response, selectedPlaceSearchDetails: nil, placeSearchResponses:checkResponses)
                                replaceIntents.append(newIntent)
                            } else if intent.placeSearchResponses.count == 0, checkResponses.count > 0 {
                                let newIntent = AssistiveChatHostIntent(caption: intent.caption, intent: intent.intent, selectedPlaceSearchResponse: nil, selectedPlaceSearchDetails: nil, placeSearchResponses:checkResponses)
                                replaceIntents.append(newIntent)
                            }
                        }
                    }
                }
            }
            
            for index in 0..<queryParametersHistory.count {
                let intentHistory = queryParametersHistory[index].queryIntents
                let selectedIntents = intentHistory.compactMap { thisIntent in
                    if thisIntent.selectedPlaceSearchResponse == nil || thisIntent.selectedPlaceSearchDetails == nil || thisIntent.placeSearchResponses.count == 0 {
                        return thisIntent
                    }
                    return nil
                }
                for intent in replaceIntents {
                    for replaceIndex in 0..<intentHistory.count {
                        let dirtyIntent = intentHistory[replaceIndex]
                        if intent.intent == dirtyIntent.intent, intent.caption == dirtyIntent.caption, selectedIntents.contains(dirtyIntent) {
                            if (intent.selectedPlaceSearchDetails != nil && dirtyIntent.selectedPlaceSearchDetails == nil)
                                || (intent.selectedPlaceSearchResponse != nil && dirtyIntent.selectedPlaceSearchResponse == nil)
                                || (intent.placeSearchResponses.count > 0 && dirtyIntent.placeSearchResponses.count == 0)
                            {
                                print("Beginning intent swap")
                                for queryIntent in queryParametersHistory[index].queryIntents {
                                    print(queryIntent.intent)
                                    print(queryIntent.caption)
                                    print(queryIntent.selectedPlaceSearchDetails == nil)
                                }
                                
                                queryParametersHistory[index].queryIntents.remove(at: replaceIndex)
                                queryParametersHistory[index].queryIntents.insert(intent, at: replaceIndex)
                                print("Checking intent swap")
                                for queryIntent in queryParametersHistory[index].queryIntents {
                                    print(queryIntent.intent)
                                    print(queryIntent.caption)
                                    print(queryIntent.selectedPlaceSearchDetails == nil)
                                }
                            } else {
                                print("Skipping swap of details")
                            }
                        }
                    }
                }
            }
        }
        
        if let lastIntent = parameters.queryIntents.last, lastIntent.caption == intent.caption, lastIntent.placeSearchResponses.count == 0, checkResponses.count > 0 {
            let newIntent = AssistiveChatHostIntent(caption: intent.caption, intent: intent.intent, selectedPlaceSearchResponse: nil, selectedPlaceSearchDetails: nil, placeSearchResponses:checkResponses)
            parameters.queryIntents.removeLast()
            parameters.queryIntents.append(newIntent)
        }
    }
    
    public func refreshModel(resultImageSize:CGSize?, queryIntents:[AssistiveChatHostIntent]? = nil, parameters:AssistiveChatHostQueryParameters) {
        guard let queryIntents = queryIntents else {
            zeroStateModel(resultImageSize: resultImageSize)
            return
        }
        
        print("Refreshing Model with intents")
        for intent in queryIntents {
            print(intent.intent)
            print(intent.caption)
        }
        
        switch queryIntents.count {
        case 0:
            zeroStateModel(resultImageSize: resultImageSize)
        default:
            if let lastIntent = queryIntents.last {
                model(resultImageSize: resultImageSize, intents: queryIntents, lastIntent:lastIntent, parameters: parameters, localPlaceSearchResponses: localPlaceSearchResponses)
            } else {
                zeroStateModel(resultImageSize: resultImageSize)
            }
        }
    }
    
    public func model(resultImageSize:CGSize?, intents:[AssistiveChatHostIntent], lastIntent:AssistiveChatHostIntent, parameters:AssistiveChatHostQueryParameters, localPlaceSearchResponses:[PlaceSearchResponse]? = nil) {
        
        switch lastIntent.intent {
        case .SaveDefault,  .SearchDefault, .RecallDefault, .OpenDefault:
            var chatResults = [ChatResult]()
            if intents.count > 0 {
                let searchResult = PlaceResponseFormatter.firstChatResult(queryIntents: intents)
                chatResults.append(searchResult)
            }
            let blendedResults = blendDefaults(with: chatResults, queryIntents:intents)
            DispatchQueue.main.async { [unowned self] in
                self.results.removeAll()
                self.results = blendedResults
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChatResultViewModelDidUpdate")))
            }
        case .TellDefault:
            let _ = Task.init {
                var chatResults = [ChatResult]()
                if intents.count > 0 {
                    let searchResult = PlaceResponseFormatter.firstChatResult(queryIntents: intents)
                    chatResults.append(searchResult)
                }
                
                let blendedResults = blendDefaults(with: chatResults, queryIntents:intents)
                DispatchQueue.main.async { [unowned self] in
                    self.results.removeAll()
                    self.results = blendedResults
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChatResultViewModelDidUpdate")))
                }
            }
        case .TellPlace:
            let _ = Task.init {
                do {
                    var chatResults = [ChatResult]()
                    var checkResponses = [PlaceSearchResponse]()
                    
                    if let placeResponse = lastIntent.selectedPlaceSearchResponse, let detailsResponse = lastIntent.selectedPlaceSearchDetails, let photosResponses = detailsResponse.photoResponses, let tipsResponses = detailsResponse.tipsResponses {
                        let results = PlaceResponseFormatter.placeDetailsChatResults(for: placeResponse, details:detailsResponse, photos: photosResponses, tips: tipsResponses, results: [placeResponse], resize:resultImageSize, queryIntents: intents)
                        chatResults.append(contentsOf:results)
                    } else {
                        if let placeResponse = lastIntent.selectedPlaceSearchResponse {
                            checkResponses.append(placeResponse)
                        } else {
                            if let currentLocation = locationProvider.currentLocation() {
                                let rawAutocompleteQuery = try await placeSearchSession.autocomplete(caption: lastIntent.caption, parameters: parameters.queryParameters, currentLocation: currentLocation.coordinate)
                                let autocompleteResponses = try PlaceResponseFormatter.autocompletePlaceSearchResponses(with: rawAutocompleteQuery)
                                checkResponses.append(contentsOf:autocompleteResponses)
                            }
                            let request = placeSearchRequest(parameters: parameters)
                            let rawQueryResponse = try await placeSearchSession.query(request:request)
                            let placeSearchResponses = try PlaceResponseFormatter.placeSearchResponses(with: rawQueryResponse)
                            checkResponses.append(contentsOf:placeSearchResponses)
                        }
                        
                        for index in 0..<min(checkResponses.count,1) {
                            let response = checkResponses[index]
                            print("Fetching photos for \(response.name)")
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
                            
                            var replaceIntents = [AssistiveChatHostIntent]()
                            for event in queryParametersHistory {
                                for index in 0..<event.queryIntents.count {
                                    let intent = event.queryIntents[index]
                                    if intent.selectedPlaceSearchResponse?.fsqID == detailsResponse.fsqID {
                                        if intent.selectedPlaceSearchDetails == nil {
                                            let newIntent = AssistiveChatHostIntent(caption: intent.caption, intent: intent.intent, selectedPlaceSearchResponse: intent.selectedPlaceSearchResponse, selectedPlaceSearchDetails: detailsResponse, placeSearchResponses: intent.placeSearchResponses)
                                            replaceIntents.append(newIntent)
                                        }
                                    }
                                }
                            }
                            
                            for index in 0..<queryParametersHistory.count {
                                let intentHistory = queryParametersHistory[index].queryIntents
                                let selectedPlacesHistory = intentHistory.compactMap { thisIntent in
                                    return thisIntent.selectedPlaceSearchResponse?.fsqID
                                }
                                if replaceIntents.contains(where: { checkIntent in
                                    if let id = checkIntent.selectedPlaceSearchResponse?.fsqID {
                                        return selectedPlacesHistory.contains(id)
                                    } else {
                                        return false
                                    }
                                }) {
                                    for intent in replaceIntents {
                                        for replaceIndex in 0..<intentHistory.count {
                                            let dirtyIntent = intentHistory[replaceIndex]
                                            if intent.intent == dirtyIntent.intent, intent.caption == dirtyIntent.caption, intent.selectedPlaceSearchResponse != nil, intent.selectedPlaceSearchResponse == dirtyIntent.selectedPlaceSearchResponse {
                                                if intent.selectedPlaceSearchDetails != nil && dirtyIntent.selectedPlaceSearchDetails == nil {
                                                    print("Beginning intent swap")
                                                    for queryIntent in queryParametersHistory[index].queryIntents {
                                                        print(queryIntent.intent)
                                                        print(queryIntent.caption)
                                                        print(queryIntent.selectedPlaceSearchDetails == nil)
                                                    }
                                                    
                                                    queryParametersHistory[index].queryIntents.remove(at: replaceIndex)
                                                    queryParametersHistory[index].queryIntents.insert(intent, at: replaceIndex)
                                                    print("Checking intent swap")
                                                    for queryIntent in queryParametersHistory[index].queryIntents {
                                                        print(queryIntent.intent)
                                                        print(queryIntent.caption)
                                                        print(queryIntent.selectedPlaceSearchDetails == nil)
                                                    }
                                                } else {
                                                    print("Skipping swap of details")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                            let results = PlaceResponseFormatter.placeDetailsChatResults(for: response, details:detailsResponse, photos: placePhotosResponses, tips: placeTipsResponses, results: checkResponses, resize:resultImageSize, queryIntents: intents)
                            chatResults.append(contentsOf:results)
                        }
                    }
                    let blendedResults = blendDefaults(with: chatResults, queryIntents: intents)
                    DispatchQueue.main.async { [unowned self] in
                        self.results.removeAll()
                        self.results = blendedResults
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChatResultViewModelDidUpdate")))
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        case .SearchPlace:
            placeQueryModel(resultImageSize: resultImageSize, query: lastIntent.caption, queryIntents: intents, parameters: parameters)
        case .SearchQuery, .TellQuery:
            searchQueryModel(resultImageSize: resultImageSize, query: lastIntent.caption, queryIntents: intents, parameters:parameters )
        default:
            let _ = Task.init {
                do {

                    var chatResults = [ChatResult]()
                    var checkResponses = [PlaceSearchResponse]()
                    
                    if let placeResponse = lastIntent.selectedPlaceSearchResponse, let detailsResponse = lastIntent.selectedPlaceSearchDetails, let photosResponses = detailsResponse.photoResponses, let tipsResponses = detailsResponse.tipsResponses {
                            let results = PlaceResponseFormatter.placeDetailsChatResults(for: placeResponse, details:detailsResponse, photos: photosResponses, tips: tipsResponses, results: [placeResponse], resize:resultImageSize, queryIntents: intents)
                            chatResults.append(contentsOf:results)
                    } else {
                        if lastIntent.placeSearchResponses.count > 0 {
                            checkResponses.append(contentsOf: lastIntent.placeSearchResponses)
                        }
                        
                        for index in 0..<min(checkResponses.count,1) {
                            let response = checkResponses[index]
                            print("Fetching photos for \(response.name)")
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
                            var replaceIntents = [AssistiveChatHostIntent]()
                            for event in queryParametersHistory {
                                for index in 0..<event.queryIntents.count {
                                    let intent = event.queryIntents[index]
                                    if intent.selectedPlaceSearchResponse?.fsqID == detailsResponse.fsqID {
                                        if intent.selectedPlaceSearchDetails == nil {
                                            let newIntent = AssistiveChatHostIntent(caption: intent.caption, intent: intent.intent, selectedPlaceSearchResponse: intent.selectedPlaceSearchResponse, selectedPlaceSearchDetails: detailsResponse, placeSearchResponses: intent.placeSearchResponses)
                                            replaceIntents.append(newIntent)
                                        }
                                    }
                                }
                            }
                            
                            for index in 0..<queryParametersHistory.count {
                                let intentHistory = queryParametersHistory[index].queryIntents
                                let selectedPlacesHistory = intentHistory.compactMap { thisIntent in
                                    return thisIntent.selectedPlaceSearchResponse?.fsqID
                                }
                                if replaceIntents.contains(where: { checkIntent in
                                    if let id = checkIntent.selectedPlaceSearchResponse?.fsqID {
                                        return selectedPlacesHistory.contains(id)
                                    } else {
                                        return false
                                    }
                                }) {
                                    for intent in replaceIntents {
                                        for replaceIndex in 0..<intentHistory.count {
                                            let dirtyIntent = intentHistory[replaceIndex]
                                            if intent.intent == dirtyIntent.intent, intent.caption == dirtyIntent.caption, intent.selectedPlaceSearchResponse != nil, intent.selectedPlaceSearchResponse == dirtyIntent.selectedPlaceSearchResponse {
                                                if intent.selectedPlaceSearchDetails != nil && dirtyIntent.selectedPlaceSearchDetails == nil {
                                                    print("Beginning intent swap")
                                                    for queryIntent in queryParametersHistory[index].queryIntents {
                                                        print(queryIntent.intent)
                                                        print(queryIntent.caption)
                                                        print(queryIntent.selectedPlaceSearchDetails == nil)
                                                    }
                                                    
                                                    queryParametersHistory[index].queryIntents.remove(at: replaceIndex)
                                                    queryParametersHistory[index].queryIntents.insert(intent, at: replaceIndex)
                                                    print("Checking intent swap")
                                                    for queryIntent in queryParametersHistory[index].queryIntents {
                                                        print(queryIntent.intent)
                                                        print(queryIntent.caption)
                                                        print(queryIntent.selectedPlaceSearchDetails == nil)
                                                    }
                                                } else {
                                                    print("Skipping swap of details")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                            let results = PlaceResponseFormatter.placeDetailsChatResults(for: response, details:detailsResponse, photos: placePhotosResponses, tips: placeTipsResponses, results: checkResponses, resize:resultImageSize, queryIntents: intents)
                            chatResults.append(contentsOf:results)
                        }
                    }
                    
                    let blendedResults = blendDefaults(with: chatResults, queryIntents: intents)
                    DispatchQueue.main.async { [unowned self] in
                        self.results.removeAll()
                        self.results = blendedResults
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChatResultViewModelDidUpdate")))
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    public func placeQueryModel(resultImageSize:CGSize?, query:String,  queryIntents:[AssistiveChatHostIntent]?, parameters:AssistiveChatHostQueryParameters ) {
        print("Refreshing model with place query parameters:\(String(describing: parameters.queryParameters))")
        
        let _ = Task.init {
            var chatResults = [ChatResult]()

                if let selectedPlaceDetailsResponse = queryIntents?.last?.selectedPlaceSearchDetails {
                    var allResponses = [PlaceDetailsResponse]()

                    allResponses.append(selectedPlaceDetailsResponse)

                    for index in 0..<min(allResponses.count,maxChatResults) {
                        
                        let response = allResponses[index]
                        let results = PlaceResponseFormatter.placeChatResults(for: response.searchResponse, details:response, resize: resultImageSize)
                        chatResults.append(contentsOf:results)
                    }
                } else if let selectedPlaceResponse = queryIntents?.last?.selectedPlaceSearchResponse {
                    var allResponses = [PlaceSearchResponse]()

                    allResponses.append(selectedPlaceResponse)

                    for index in 0..<min(allResponses.count,maxChatResults) {
                        
                        let response = allResponses[index]
                        let results = PlaceResponseFormatter.placeChatResults(for: response, resize: resultImageSize)
                        chatResults.append(contentsOf:results)
                    }
                } else if let backupResponses = queryIntents?.last?.placeSearchResponses, backupResponses.count > 0 {
                    var allResponses = [PlaceSearchResponse]()

                    allResponses.append(contentsOf: backupResponses)

                    for index in 0..<min(allResponses.count,maxChatResults) {
                        
                        let response = allResponses[index]
                        let results = PlaceResponseFormatter.placeChatResults(for: response, resize: resultImageSize)

                        chatResults.append(contentsOf:results)
                    }
                }
                
                let blendedResults = blendDefaults(with: chatResults)
                DispatchQueue.main.async { [unowned self] in
                    self.localPlaceSearchResponses = queryIntents?.last?.placeSearchResponses
                    self.results.removeAll()
                    self.results = blendedResults
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChatResultViewModelDidUpdate")))
                }
        }
    }
    
    public func searchQueryModel(resultImageSize:CGSize?, query:String,  queryIntents:[AssistiveChatHostIntent]?, parameters:AssistiveChatHostQueryParameters ) {
        print("Refreshing model with search query parameters:\(String(describing: parameters.queryParameters))")
        let _ = Task.init {
                guard let placeSearchResponses = queryIntents?.last?.placeSearchResponses else {
                    return
                }
                
                var allResponses = [PlaceSearchResponse]()
                if let selectedPlaceResponse = queryIntents?.last?.selectedPlaceSearchResponse {
                    allResponses.append(selectedPlaceResponse)
                }
                allResponses.append(contentsOf: placeSearchResponses)
                
                var chatResults = [ChatResult]()
                for index in 0..<min(allResponses.count,maxChatResults) {
                    let response = allResponses[index]
                    let results = PlaceResponseFormatter.placeChatResults(for: response, resize: resultImageSize, queryIntents: queryIntents)
                    chatResults.append(contentsOf:results)
                }
                
                let blendedResults = blendDefaults(with: chatResults)
                let finalResponses = allResponses
                DispatchQueue.main.async { [unowned self] in
                    self.localPlaceSearchResponses = finalResponses
                    self.results.removeAll()
                    self.results = blendedResults
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChatResultViewModelDidUpdate")))
                }
        }

    }
        
    public func zeroStateModel(resultImageSize:CGSize?) {
        let blendedResults = blendDefaults(with: [])
        DispatchQueue.main.async { [unowned self] in
            self.results.removeAll()
            self.results = blendedResults
        }
    }
    
    private func blendDefaults(with chatResults:[ChatResult], queryIntents:[AssistiveChatHostIntent]? = nil)->[ChatResult] {
        var defaultResults = ChatResultViewModel.modelDefaults
        defaultResults.append(contentsOf: chatResults)
        
        if let queryIntents = queryIntents, let lastIntent = queryIntents.last?.intent {
            var results = chatResults
            var defaults = ChatResultViewModel.modelDefaults
            switch lastIntent{
            case .SaveDefault:
                return results
            case .SearchDefault:
                defaults.remove(at: 0)
                return defaults
            case .RecallDefault:
                return results
            case  .TellDefault: 
                defaults.remove(at: 0)
                results.append(contentsOf: defaults)
                return results
            case .OpenDefault:
                results.append(contentsOf: defaults)
                return results
            default:
                results.append(contentsOf: defaults)
                return results
            }
        } else {
            return defaultResults
        }
    }
    
    
    private func placeSearchRequest(parameters:AssistiveChatHostQueryParameters )->PlaceSearchRequest {
        var query = ""

        
        if let caption = parameters.queryIntents.last?.caption {
            let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass])
            tagger.string = caption
            
            let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
            let tags: [NLTag] = [.personalName, .placeName, .organizationName, .noun, .adjective]
            var nameString:String = ""
            
            tagger.enumerateTags(in: caption.startIndex..<caption.endIndex, unit: .word, scheme: .nameTypeOrLexicalClass, options: options) { tag, tokenRange in
                // Get the most likely tag, and print it if it's a named entity.
                if let tag = tag, tags.contains(tag) {
                    print("\(caption[tokenRange]): \(tag.rawValue)")
                    nameString.append("\(caption[tokenRange]) ")
                }
                
                // Get multiple possible tags with their associated confidence scores.
                let (hypotheses, _) = tagger.tagHypotheses(at: tokenRange.lowerBound, unit: .word, scheme: .nameTypeOrLexicalClass, maximumCount: 1)
                print(hypotheses)
                
                return true
            }
            query.append(nameString)
            query.append(" ")
        }
        
        var ll:String? = nil
        var openNow = false
        var openAt:String? = nil
        var nearLocation:String? = nil
        var minPrice = 1
        var maxPrice = 4
        var radius = 1000
        var sort:String? = nil
        if let rawParameters = parameters.queryParameters?["parameters"] as? NSDictionary {
            if let rawMinPrice = rawParameters["min_price"] as? Int, rawMinPrice > 1 {
                minPrice = rawMinPrice
            }
            
            if let rawMaxPrice = rawParameters["max_price"] as? Int, rawMaxPrice < 4 {
                maxPrice = rawMaxPrice
            }
            
            if let rawRadius = rawParameters["radius"] as? Int, rawRadius > 0 {
                radius = rawRadius
            }
            
            if let rawSort = rawParameters["sort"] as? String {
                sort = rawSort
            }
            
            /*
            if let rawCategories = rawParameters["categories"] as? [NSDictionary] {
                for rawCategory in rawCategories {
                    if let categoryName = rawCategory["name"] as? String {
                        //query.append("\(categoryName) ")
                    }
                }
            }
             */
            
            if let rawTips = rawParameters["tips"] as? [String] {
                for rawTip in rawTips {
                    if !query.contains(rawTip) {
                        query.append("\(rawTip) ")
                    }
                }
            }
            
            if let rawTastes = rawParameters["tastes"] as? [String] {
                for rawTaste in rawTastes {
                    if !query.contains(rawTaste) {
                        query.append("\(rawTaste) ")
                    }
                }
            }
            
            
            if let rawNear = rawParameters["near"] as? [String], let firstNear = rawNear.first, firstNear.count > 0 {
                nearLocation = rawNear.first
            }
            
            if let rawOpenAt = rawParameters["open_at"] as? String, rawOpenAt.count > 0 {
                openAt = rawOpenAt
            }
            
            if let rawOpenNow = rawParameters["open_now"] as? Bool {
                openNow = rawOpenNow
            }
        }
        
        print("Created query for search request:\(query) near location:\(String(describing: nearLocation))")
        if nearLocation == nil {
            let location = locationProvider.currentLocation()
            if let l = location {
                ll = "\(l.coordinate.latitude),\(l.coordinate.longitude)"
            }
            
            print("Did not find a location in the query, using current location:\(String(describing: ll))")
        }
        
        let request = PlaceSearchRequest(query:query.trimmingCharacters(in: .whitespacesAndNewlines), ll: ll, radius:radius, categories: nil, fields: nil, minPrice: minPrice, maxPrice: maxPrice, openAt: openAt, openNow: openNow, nearLocation: nearLocation, sort: sort)
        return request
    }
}
