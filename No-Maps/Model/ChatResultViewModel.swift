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

    private static let modelDefaults:[ChatResult] = [
        ChatResult(title: "I like a place", backgroundColor: Color.green, backgroundImageURL: nil, placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil),
        ChatResult(title: "Where can I find", backgroundColor: Color.green, backgroundImageURL: nil,  placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil),
        ChatResult(title: "What did I like", backgroundColor: Color.green, backgroundImageURL: nil,  placeResponse: nil, placeDetailsResponse: nil, photoResponse: nil),
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
    
    public func applyQuery(caption:String, parameters:AssistiveChatHostQueryParameters, history:[AssistiveChatHostQueryParameters]) {
        print("Applying query: \(caption)")
        print("With parameters:")
        for intent in parameters.queryIntents {
            print(intent.caption)
            print(intent.intent)
        }
        
         
    }
    
    public func refreshModel(resultImageSize:CGSize?, queryIntents:[AssistiveChatHostIntent]? = nil) {
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
                model(resultImageSize: resultImageSize, intents: queryIntents, lastIntent:lastIntent, localPlaceSearchResponses: localPlaceSearchResponses)
            } else {
                zeroStateModel(resultImageSize: resultImageSize)
            }
        }
    }
    
    public func model(resultImageSize:CGSize?, intents:[AssistiveChatHostIntent], lastIntent:AssistiveChatHostIntent, localPlaceSearchResponses:[PlaceSearchResponse]? = nil) {
        guard let localPlaceSearchResponses = localPlaceSearchResponses else {
            zeroStateModel(resultImageSize: resultImageSize)
            return
        }
        
        switch lastIntent.intent {
        case .SaveDefault, .TellDefault, .SearchDefault, .RecallDefault, .OpenDefault:
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
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChatResultViewScrollToZero")))
                }
            }
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
                            let results = PlaceResponseFormatter.placeDetailsChatResults(for: response, details:detailsResponse, photos: placePhotosResponses, tips: placeTipsResponses, results: checkResponses, resize:resultImageSize, queryIntents: intents)
                            chatResults.append(contentsOf:results)
                        }
                    }
                    
                    let blendedResults = blendDefaults(with: chatResults, queryIntents: intents)
                    DispatchQueue.main.async { [unowned self] in
                        self.results.removeAll()
                        self.results = blendedResults
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ChatResultViewScrollToZero")))
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
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
                }
                let request = PlaceSearchRequest(query: "", ll: locationString, categories: nil, fields: nil, openNow: true, nearLocation: nil)
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
                defaults.remove(at: 0)
                defaults.insert(searchResult, at: 0)
                results.append(contentsOf: defaults)
                return results
            case .SearchDefault:
                defaults.remove(at: 1)
                defaults.insert(searchResult, at: 1)
                results.append(contentsOf: defaults)
                return results
            case .RecallDefault:
                defaults.remove(at: 2)
                defaults.insert(searchResult, at: 2)
                results.append(contentsOf: defaults)
                return results
            case  .TellDefault:
                defaults.remove(at: 3)
                defaults.insert(searchResult, at: 3)
                results.append(contentsOf: defaults)
                return results
            case .OpenDefault:
                defaults.remove(at: 4)
                defaults.insert(searchResult, at: 0)
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
