//
//  ChatResultViewModel.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/20/23.
//

import SwiftUI

public class ChatResultViewModel : ObservableObject {
    private var placeSearchSession:PlaceSearchSession = PlaceSearchSession()
    private var locationProvider:LocationProvider = LocationProvider()
    private let maxChatResults:Int = 7
    
    private static let modelDefaults:[ChatResult] = [
        ChatResult(title: "I like a place", backgroundColor: Color.blue, backgroundImageURL: nil),
        ChatResult(title: "Where can I find", backgroundColor: Color.blue, backgroundImageURL: nil),
        ChatResult(title: "Where did I like", backgroundColor: Color.blue, backgroundImageURL: nil),
    ]

    
    @Published public var results:[ChatResult] = ChatResultViewModel.modelDefaults

    public func authorizeLocationProvider() {
        locationProvider.authorize()
    }
    
    public func refreshModel(resultImageSize:CGSize?) {
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
                    print("Fetching photos for \(response.name)")
                    let rawPhotosResponse = try await placeSearchSession.photos(for: response.fsqID)
                    
                    let placePhotosResponses = try PlaceResponseFormatter.placePhotoResponses(with: rawPhotosResponse, for:response.fsqID)
                    
                    /*
                     let placeDetailsResponse = try await placeSearchSession.details(for: response.fsqID)
                     print(placeDetailsResponse)
                     
                     
                     let rawTipsResponse = try await placeSearchSession.tips(for: response.fsqID)
                     let placeTipsResponses = try PlaceResponseFormatter.placeTipsResponses(with: rawTipsResponse, for:response.fsqID)
                     */
                    
                    let result = PlaceResponseFormatter.chatResult(for: response, photos: placePhotosResponses, resize: resultImageSize)
                    chatResults.append(result)
                }
                
                let blendedResults = blendDefaults(with: chatResults)
                DispatchQueue.main.async { [unowned self] in
                    self.results = blendedResults
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func blendDefaults(with chatResults:[ChatResult])->[ChatResult] {
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
    
}
