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
    func fetchSearchQueryParameters( with query:String) async throws -> String
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
            retval.append("\n")
        }
        
        var tastesSummary = ""
        if let tastes = detailsResponse.tastes {
            let summary = try await fetchTastesSummary(with: searchResponse.name, tastes: tastes)
            tastesSummary.append(summary)
            print("Tastes Summary")
            print(summary)
        }
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
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
        
        retval.append(tastesSummary)
        if tastesSummary.count > 0 {
            retval.append("\n")
        }
        
        if tipsSummary.count > 0 {
            retval.append("\n")
        }
        retval.append(tipsSummary)
        
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
    
    public func fetchSearchQueryParameters( with query:String) async throws -> String {
        var prompt = """
        Specify these queries as a JSON dictionary of Foursquare API search parameters:
                [{
                "query":"I want a Seafood place near Lake Como, Italy that is not that expensive for lunch which has a view of the lake.",
                "parameters":{
                 "near": ["Lake Como, Italy"],
                 "radius":2000,
                 "min_price":1,
                 "max_price":2,
                 "open_at":"0T1200",
                 "open_now":false,
                 "sort":"distance",
                 "tips":[],
                 "tastes":[],
                 "categories": [
                        {
                          "naics_code": 13065,
                          "name": "Restaurant"
                        },
                        {
                          "naics_code": 13338,
                          "name": "Seafood Restaurant"
                        }
                      ]
                }
                },
                {
                "query":"Where is a place in Hudson Yards that we can get a glass of prosecco and some olives right now?",
                "parameters":{
                 "near": ["Manhattan","Hudson Yards"],
                 "radius":1000,
                 "min_price":1,
                 "max_price":4,
                 "open_at":"",
                 "open_now":true,
                 "sort":"relevance",
                 "tips":[],
                 "tastes":["prosecco","olives"],
                 "categories": [
                        {
                          "naics_code": 13065,
                          "name": "Restaurant"
                        }
                      ]
                }
                },
                {
                "query":"Where can I take my parents for dinner on Saturday that has Michelin star rated sushi?",
                "parameters":{
                 "near": ["Manhattan"],
                 "radius":2000,
                 "min_price":2,
                 "max_price":4,
                 "open_at":"6T1600",
                 "open_now":false,
                 "sort":"rating",
                 "tips":[],
                 "tastes":["sushi"],
                 "categories": [
                        {
                          "naics_code": 13263,
                          "name": "Japanese Restaurant"
                        }
                      ]
                }
                },
                {
                "query":"What's a place in Williamsburg that I can get some absinthe and oysters?",
                "parameters":{
                 "near": ["Brooklyn", "Williamsburg"],
                 "radius":2000,
                 "min_price":2,
                 "max_price":4,
                 "open_at":"",
                 "open_now":false,
                 "sort":"relevance",
                 "tips":[],
                 "tastes":["absinthe", "oysters"],
                 "categories": [
                        {
                          "naics_code": 13065,
                          "name": "Restaurant"
                        }
                      ]
                }
                },
                {
                "query":"What bar has the best fireplace in the West Village?",
                "parameters":{
                 "near": ["Manhattan", "West Village"],
                 "radius":1000,
                 "min_price":1,
                 "max_price":4,
                 "open_at":"",
                 "open_now":false,
                 "sort":"rating",
                 "tips":[],
                 "tastes":["fireplace"],
                 "categories": [
                        {
                          "naics_code": 13009,
                          "name": "Cocktail Bar"
                        }
                      ]
                }
                },
                {"query":"What's a nice park in Brooklyn that I can take my kids to after school?",
                "parameters":{
                 "near": ["Brooklyn"],
                 "radius":2000,
                 "min_price":1,
                 "max_price":4,
                 "open_at":"0T1500",
                 "open_now":false,
                 "sort":"rating",
                 "tips":[],
                 "tastes":["park", "kids"],
                 "categories": [
                        {
                          "naics_code": 16037,
                          "name": "Playground"
                        },
                        {
                          "naics_code": 16017,
                          "name": "Garden"
                        }
                      ]
                }
                },
                {
                "query":"Where can I get handmade Neopolitan pizza in Soho after shopping at noon?",
                "parameters":{
                 "near": ["Manhattan", "Soho"],
                 "radius":1000,
                 "min_price":2,
                 "max_price":4,
                 "open_at":"0T1200",
                 "open_now":false,
                 "sort":"relevance",
                 "tips":[],
                 "tastes":["neopolitan", "pizza"],
                 "categories": [
                        {
                          "naics_code": 13064,
                          "name": "Pizzeria"
                        }
                      ]
                }
                },
                {
                "query":"What museums or galleries have new media installations in Berlin?",
                "parameters":{
                 "near": ["Germany", "Berlin"],
                 "radius":2000,
                 "min_price":1,
                 "max_price":4,
                 "open_at":"",
                 "open_now":false,
                 "sort":"rating",
                 "tips":[],
                 "tastes":["new media", "installations"],
                 "categories": [
                        {
                          "naics_code": 10028,
                          "name": "Art Museum"
                        },
                        {
                          "naics_code": 10027,
                          "name": "Museum"
                        }
                      ]
                }
                },
        {"query":"
        """
        
        prompt.append(query)
        prompt.append("\",")
        
        let request = LanguageGeneratorRequest(model: "text-davinci-003", prompt: prompt, maxTokens: 200, temperature: 0, stop: nil, user: nil)
        let rawResponse = try await session.query(languageGeneratorRequest: request)
        if let rawResponse = rawResponse, let choices = rawResponse["choices"] as? [NSDictionary] {
            if let firstChoice = choices.first, let text = firstChoice["text"] as? String {
                let repair = "[{\"query\":\"\(query)\","
                return repair.appending(text)
            }
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
