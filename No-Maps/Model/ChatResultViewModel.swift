//
//  ChatResultViewModel.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/20/23.
//

import SwiftUI

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
        ChatResult(title: "Where can I find", backgroundColor: Color.green, backgroundImageURL: nil,  placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil),
        ChatResult(title: "Tell me about", backgroundColor: Color.green, backgroundImageURL: nil,  placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil),
        ChatResult(title: "Ask a different question", backgroundColor: Color.red, backgroundImageURL: nil, placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil)
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
    
    public func receiveMessage(caption: String, parameters: AssistiveChatHostQueryParameters, isLocalParticipant: Bool) {
        queryCaption = caption
        queryParametersHistory.append(parameters)
        applyQuery(caption: queryCaption!, parameters: parameters, history: queryParametersHistory)
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
    applyQuery(caption:String, parameters:AssistiveChatHostQueryParameters, history:[AssistiveChatHostQueryParameters]) {
        print("Applying query: \(caption)")
        print("With parameters:")
        for intent in parameters.queryIntents {
            print(intent.caption)
            print(intent.intent)
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
        guard let localPlaceSearchResponses = localPlaceSearchResponses else {
            zeroStateModel(resultImageSize: resultImageSize)
            return
        }
        
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
                for index in 0..<min(localPlaceSearchResponses.count,maxChatResults) {
                    
                    let response = localPlaceSearchResponses[index]
                    let placePhotosResponses = [PlacePhotoResponse]()
                    
                    let results = PlaceResponseFormatter.placeChatResults(for: response, photos: placePhotosResponses, resize: resultImageSize, queryIntents: intents)
                    chatResults.append(contentsOf:results)
                }
                
                let blendedResults = blendDefaults(with: chatResults, queryIntents:intents)
                DispatchQueue.main.async { [unowned self] in
                    self.results.removeAll()
                    self.results = blendedResults
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChatResultViewModelDidUpdate")))
                }
            }
        case .SearchQuery:
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
                        
                        for localPlaceSearchResponse in localPlaceSearchResponses {
                            let foundResponse = checkResponses.contains { thisReponse in
                                return thisReponse.fsqID == localPlaceSearchResponse.fsqID
                            }
                            if(!foundResponse) {
                                checkResponses.append(localPlaceSearchResponse)
                            }
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
                                    var intent = event.queryIntents[index]
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
    
    public func searchQueryModel(resultImageSize:CGSize?, query:String,  queryIntents:[AssistiveChatHostIntent]?, parameters:AssistiveChatHostQueryParameters ) {
        print("Refreshing model with search query parameters:\(parameters.queryParameters)")
        let _ = Task.init {
            do {
                var query = ""
                var ll:String? = nil
                var openNow = false
                var openAt:String? = nil
                var nearLocation:String? = nil
                var minPrice = 1
                var maxPrice = 4
                var radius:Int? = nil
                var sort:String? = nil
                if let rawParameters = parameters.queryParameters?["parameters"] as? NSDictionary {
                    if let rawMinPrice = rawParameters["min_price"] as? Int, rawMinPrice > 1 {
                        minPrice = rawMinPrice
                    }
                    
                    if let rawMaxPrice = rawParameters["max_price"] as? Int, rawMaxPrice < 4 {
                        maxPrice = rawMaxPrice
                    }
                    
                    if let rawRadius = rawParameters["radius"] as? Int {
                        radius = rawRadius
                    }
                    
                    if let rawSort = rawParameters["sort"] as? String {
                        sort = rawSort
                    }
                    
                    if let rawCategories = rawParameters["categories"] as? [NSDictionary] {
                        for rawCategory in rawCategories {
                            if let categoryName = rawCategory["name"] as? String {
                                query.append("\(categoryName) ")
                            }
                        }
                    }
                    
                    if let rawTips = rawParameters["tips"] as? [String] {
                        for rawTip in rawTips {
                            query.append("\(rawTip) ")
                        }
                    }
                    
                    if let rawTastes = rawParameters["tastes"] as? [String] {
                        for rawTaste in rawTastes {
                            query.append("\(rawTaste)")
                        }
                    }
                    
                    
                    if let rawNear = rawParameters["near"] as? [String] {
                        nearLocation = rawNear.first
                        if rawNear.count > 1, let last = rawNear.last {
                            query.append("in \(last) ")
                        }
                    }
                    
                    if let rawOpenAt = rawParameters["open_at"] as? String, rawOpenAt.count > 0 {
                        openAt = rawOpenAt
                    }
                    
                    if let rawOpenNow = rawParameters["open_now"] as? Bool {
                        openNow = rawOpenNow
                    }
                }
                
                print("Created query for search request:\(query) near location:\(nearLocation)")
                if nearLocation == nil {
                    let location = locationProvider.currentLocation()
                    if let l = location {
                        ll = "\(l.coordinate.latitude),\(l.coordinate.longitude)"
                    }
                    
                    print("Did not find a location in the query, using current location:\(ll)")
                }
                var request = PlaceSearchRequest(query:query, ll: ll, radius:radius ?? 250, categories: nil, fields: nil, minPrice: minPrice, maxPrice: maxPrice, openAt: openAt, openNow: openNow, nearLocation: nearLocation, sort: sort)
                
                let rawQueryResponse = try await placeSearchSession.query(request:request)
                let placeSearchResponses = try PlaceResponseFormatter.placeSearchResponses(with: rawQueryResponse)
                
                var chatResults = [ChatResult]()
                for index in 0..<min(placeSearchResponses.count,maxChatResults) {
                    
                    let response = placeSearchResponses[index]
                    print("Fetching photos for \(response.name)")
                    let rawPhotosResponse = try await placeSearchSession.photos(for: response.fsqID)
                    let placePhotosResponses = try PlaceResponseFormatter.placePhotoResponses(with: rawPhotosResponse, for:response.fsqID)
                    let placeDetailsRequest = PlaceDetailsRequest(fsqID: response.fsqID, description: true, tel: true, fax: false, email: false, website: true, socialMedia: true, verified: false, hours: true, hoursPopular: true, rating: true, stats: false, popularity: true, price: true, menu: true, tastes: true, features: false)
                     let placeDetailsResponse = try await placeSearchSession.details(for: placeDetailsRequest)
                     print(placeDetailsResponse)
                     let rawTipsResponse = try await placeSearchSession.tips(for: response.fsqID)
                     let placeTipsResponses = try PlaceResponseFormatter.placeTipsResponses(with: rawTipsResponse, for:response.fsqID)
                    let results = PlaceResponseFormatter.placeChatResults(for: response, photos: placePhotosResponses, resize: resultImageSize, queryIntents: queryIntents)
                    chatResults.append(contentsOf:results)
                }
                
                let blendedResults = blendDefaults(with: chatResults)
                DispatchQueue.main.async { [unowned self] in
                    self.localPlaceSearchResponses = placeSearchResponses
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
        
    public func zeroStateModel(resultImageSize:CGSize?) {
        let location = locationProvider.currentLocation()
        let _ = Task.init {
            do {
                var locationString = ""
                if let l = location {
                    locationString = "\(l.coordinate.latitude),\(l.coordinate.longitude)"
                    print("Fetching places with location string: \(locationString)")
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
                        self.zeroStateModel(resultImageSize: resultImageSize)
                    }
                    return
                }
                let request = PlaceSearchRequest(query: "", ll: locationString, categories: nil, fields: nil, openAt: nil, openNow: true, nearLocation: nil, sort: nil)
                let rawQueryResponse = try await placeSearchSession.query(request:request)
                let placeSearchResponses = try PlaceResponseFormatter.placeSearchResponses(with: rawQueryResponse)
                
                var chatResults = [ChatResult]()
                for index in 0..<min(placeSearchResponses.count,maxChatResults) {
                    
                    let response = placeSearchResponses[index]
//                    print("Fetching photos for \(response.name)")
//                    let rawPhotosResponse = try await placeSearchSession.photos(for: response.fsqID)
//
//                    let placePhotosResponses = try PlaceResponseFormatter.placePhotoResponses(with: rawPhotosResponse, for:response.fsqID)
                    
                    let placePhotosResponses = [PlacePhotoResponse]()
                    /*
                     let placeDetailsResponse = try await placeSearchSession.details(for: response.fsqID)
                     print(placeDetailsResponse)
                     
                     
                     let rawTipsResponse = try await placeSearchSession.tips(for: response.fsqID)
                     let placeTipsResponses = try PlaceResponseFormatter.placeTipsResponses(with: rawTipsResponse, for:response.fsqID)
                     */
                    
                    let results = PlaceResponseFormatter.placeChatResults(for: response, photos: placePhotosResponses, resize: resultImageSize, queryIntents: nil)
                    chatResults.append(contentsOf:results)
                }
                
                let blendedResults = blendDefaults(with: chatResults)
                DispatchQueue.main.async { [unowned self] in
                    self.localPlaceSearchResponses = placeSearchResponses
                    self.results.removeAll()
                    self.results = blendedResults
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }

    }
    
    private func blendDefaults(with chatResults:[ChatResult], queryIntents:[AssistiveChatHostIntent]? = nil)->[ChatResult] {
        var defaultResults = ChatResultViewModel.modelDefaults
        defaultResults.append(contentsOf: chatResults)
        
        if let queryIntents = queryIntents, let lastIntent = queryIntents.last?.intent {
            var results = chatResults
            var defaults = ChatResultViewModel.modelDefaults
            let searchResult = PlaceResponseFormatter.firstChatResult(queryIntents: queryIntents)
            switch lastIntent{
            case .SaveDefault:
                return results
            case .SearchDefault:
                defaults.remove(at: 0)
                return defaults
            case .RecallDefault:
                return results
            case  .TellDefault:
                defaults.remove(at: 1)
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
}
