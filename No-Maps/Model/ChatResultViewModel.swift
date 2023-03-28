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
    private let maxChatResults:Int = 7
    
    private static let modelDefaults:[ChatResult] = [
        ChatResult(title: "I like a place", backgroundColor: Color.green, backgroundImageURL: nil),
        ChatResult(title: "Where can I find", backgroundColor: Color.green, backgroundImageURL: nil),
        ChatResult(title: "What did I like", backgroundColor: Color.green, backgroundImageURL: nil),
        ChatResult(title: "Tell me about", backgroundColor: Color.green, backgroundImageURL: nil),
    ]

    
    @Published public var results:[ChatResult] = ChatResultViewModel.modelDefaults

    public func authorizeLocationProvider() {
        locationProvider.authorize()
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
        
        let _ = Task.init {
            do {
                var chatResults = [ChatResult]()
                let searchResult = PlaceResponseFormatter.searchChatResult(queryIntents: intents)
                chatResults.append(searchResult)
                for index in 0..<min(localPlaceSearchResponses.count,maxChatResults) {
                    
                    let response = localPlaceSearchResponses[index]
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
                    
                    let result = PlaceResponseFormatter.placeChatResult(for: response, photos: placePhotosResponses, resize: resultImageSize, queryIntents: intents)
                    chatResults.append(result)
                }
                
                let blendedResults = blendDefaults(with: chatResults, queryIntents:intents)
                DispatchQueue.main.async { [unowned self] in
                    self.results = blendedResults
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
                    
                    let result = PlaceResponseFormatter.placeChatResult(for: response, photos: placePhotosResponses, resize: resultImageSize, queryIntents: nil)
                    chatResults.append(result)
                }
                
                let blendedResults = blendDefaults(with: chatResults)
                DispatchQueue.main.async { [unowned self] in
                    self.localPlaceSearchResponses = placeSearchResponses
                    self.results = blendedResults
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }

    }
    
    private func blendDefaults(with chatResults:[ChatResult], queryIntents:[AssistiveChatHostIntent]? = nil)->[ChatResult] {
        var zeroStateResults:()->[ChatResult] = {
            var blendResults = [ChatResult]()
            
            let finalArrayCount = chatResults.count + ChatResultViewModel.modelDefaults.count
            var countDefaults = 0
            var countResults = 0
            for index in 0..<finalArrayCount {
                let position = index % 2
                switch position{
                case 0:
                    if countDefaults < ChatResultViewModel.modelDefaults.count {
                        let result = ChatResultViewModel.modelDefaults[countDefaults]
                        blendResults.append(result)
                        countDefaults += 1
                    } else if countResults < chatResults.count {
                        let result = chatResults[countResults]
                        blendResults.append(result)
                        countResults += 1
                    }
                case 1:
                    if countDefaults < ChatResultViewModel.modelDefaults.count {
                        let result = ChatResultViewModel.modelDefaults[countDefaults]
                        blendResults.append(result)
                        countDefaults += 1
                    } else if countResults < chatResults.count {
                        let result = chatResults[countResults]
                        blendResults.append(result)
                        countResults += 1
                    }
                default:
                    break
                }
            }
            return blendResults
        }
        
        
        guard let queryIntents = queryIntents else {
            return zeroStateResults()
        }
        
        var blendedResults = chatResults
        blendedResults.append(contentsOf: ChatResultViewModel.modelDefaults)
        
        return blendedResults
    }
}
