//
//  LanguageGenerator.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/3/23.
//

import Foundation
import CoreLocation

public protocol LanguageGeneratorDelegate {
    func searchQueryDescription(nearLocation:CLLocation) async throws -> String
    func placeDescription(searchResponse:PlaceSearchResponse, detailsResponse:PlaceDetailsResponse) async throws -> String
}


open class LanguageGenerator : LanguageGeneratorDelegate {
    private var session:LanguageGeneratorSession = LanguageGeneratorSession()
    
    public func searchQueryDescription(nearLocation:CLLocation) async throws -> String {
        let retval = "Sorted by distance"
        
        let placemark = await withUnsafeContinuation { continuation in
            lookUpLocation(location: nearLocation) { placemark in
                continuation.resume(returning: placemark)
            }
        }
        
        if let name = placemark?.name {
            return retval.appending(" from \(name):")
        } else {
            return retval.appending(":")
        }
    }
    
    public func placeDescription(searchResponse: PlaceSearchResponse, detailsResponse: PlaceDetailsResponse) async throws -> String {
        var retval = ""
        
        if let description = detailsResponse.description {
            retval = description
            retval.append("\n\n")
        }
        
        var tipsSummary = ""
        
        if let tips = detailsResponse.tipsResponses {
            let tipsText = tips.compactMap { response in
                return response.text
            }
            
            let summary = try await fetchTipsSummary(with:searchResponse.name,tips:tipsText)
            print("Tips Summary")
            print(summary)
            tipsSummary.append(summary)
        }
        
        if tipsSummary.count > 0 {
            retval.append(tipsSummary)
        } else {
            var tastesSummary = ""
            
            if let tastes = detailsResponse.tastes {
                let summary = try await fetchTastesSummary(with: searchResponse.name, tastes: tastes)
                tastesSummary.append(summary)
                print("Tastes Summary")
                print(summary)
            }
            
            if tastesSummary.count > 0 {
                retval.append("\n")
                retval.append(tastesSummary)
            }
        }
        
        if retval.count == 0 {
            retval = "No description, tips, or tastes for \(searchResponse.name) are recorded."
        }
        
        return retval
    }
    
    
    public func fetchTastesSummary(with placeName:String, tastes:[String]) async throws -> String {
        var prompt = "Write a description of \(placeName) that is known for "
        for taste in tastes {
            prompt.append(" \(taste),")
        }
        prompt.append("\(placeName) is")
        let request = LanguageGeneratorRequest(model: "text-davinci-003", prompt: prompt, maxTokens: 200, temperature: 0, stop: nil, user: nil)
        let rawResponse = try await session.query(languageGeneratorRequest: request)
        if let rawResponse = rawResponse, let choices = rawResponse["choices"] as? [NSDictionary] {
            if let firstChoice = choices.first, let text = firstChoice["text"] as? String {
                return "\(placeName) is\(text)"
            }
        } else {
            print("error fetching tastes summary:\(String(describing: rawResponse))")
        }
        return ""
    }
    
    public func fetchTipsSummary(with placeName:String, tips:[String]) async throws -> String {
        if tips.count == 1 {
            return tips.first!
        }
        
        var prompt = "Combine these reviews into an honest description:"
        for tip in tips {
            prompt.append("\n\(tip)")
        }
        prompt.append("\(placeName) is")
        let request = LanguageGeneratorRequest(model: "text-davinci-003", prompt: prompt, maxTokens: 200, temperature: 0, stop: nil, user: nil)
        let rawResponse = try await session.query(languageGeneratorRequest: request)
        if let rawResponse = rawResponse, let choices = rawResponse["choices"] as? [NSDictionary] {
            if let firstChoice = choices.first, let text = firstChoice["text"] as? String {
                return "\(placeName) is\(text)"
            }
        } else {
            print("error fetching tips summary:\(String(describing: rawResponse))")
        }
        return ""
    }
}

extension LanguageGenerator {
    func lookUpLocation(location:CLLocation, completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        // Use the last reported location.
        let geocoder = CLGeocoder()
            
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(location,
                    completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
             // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
}
