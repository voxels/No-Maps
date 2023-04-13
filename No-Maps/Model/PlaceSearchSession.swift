//
//  PlacesSearchSession.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/19/23.
//

import Foundation
import CloudKit

public enum PlaceSearchSessionError : Error {
    case ServiceNotFound
    case UnsupportedRequest
}

open class PlaceSearchSession : ObservableObject {
    private var foursquareApiKey = ""
    private var searchSession:URLSession?
    let keysContainer = CKContainer(identifier:"iCloud.com.noisederived.No-Maps.Keys")
    static let serverUrl = "https://api.foursquare.com/"
    static let placeSearchAPIUrl = "v3/places/search"
    static let placeDetailsAPIUrl = "v3/places/"
    static let placePhotosAPIUrl = "/photos"
    static let placeTipsAPIUrl = "/tips"
    
    public enum PlaceSearchService : String {
        case foursquare
    }
    
    init(){
        
    }
    
    init(foursquareApiKey: String = "", foursquareSession: URLSession? = nil) {
        self.foursquareApiKey = foursquareApiKey
        self.searchSession = foursquareSession
        if let containerIdentifier = keysContainer.containerIdentifier {
            print(containerIdentifier)
        }
    }
    
    public func query(request:PlaceSearchRequest) async throws ->NSDictionary {
        if searchSession == nil {
            searchSession = try await session()
        }
        
        var components = URLComponents(string:"\(PlaceSearchSession.serverUrl)\(PlaceSearchSession.placeSearchAPIUrl)")
        let queryItem = URLQueryItem(name: "query", value: request.query)
        let locationQueryItem = URLQueryItem(name: "ll", value: request.ll)
        let radiusQueryItem = URLQueryItem(name: "radius", value: "\(request.radius)")
        components?.queryItems = [queryItem, locationQueryItem, radiusQueryItem]
        
        guard let url = components?.url else {
            throw PlaceSearchSessionError.UnsupportedRequest
        }
        
        let placeSearchResponse = try await fetch(url: url, apiKey: self.foursquareApiKey)
        
        guard let response = placeSearchResponse as? NSDictionary else {
            return NSDictionary()
        }
                
        return response
    }
    
    public func details(for request:PlaceDetailsRequest) async throws -> Any {
        if searchSession == nil {
            searchSession = try await session()
        }
        
        var components = URLComponents(string:"\(PlaceSearchSession.serverUrl)\(PlaceSearchSession.placeDetailsAPIUrl)\(request.fsqID)")
        var detailsString = ""
        
        if request.description{
            detailsString.append("description,")
        }
        if request.tel {
            detailsString.append("tel,")
        }
        if request.fax{
            detailsString.append("fax,")
        }
        if request.email{
            detailsString.append("email,")
        }
        if request.website{
            detailsString.append("website,")
        }
        if request.socialMedia{
            detailsString.append("social_media,")
        }
        if request.verified{
            detailsString.append("verified,")
        }
        if request.hours{
            detailsString.append("hours,")
        }
        if request.hoursPopular{
            detailsString.append("hours_popular,")
        }
        if request.rating{
            detailsString.append("rating,")
        }
        if request.stats{
            detailsString.append("stats,")
        }
        if request.popularity{
            detailsString.append("popularity,")
        }
        if request.price{
            detailsString.append("price,")
        }
        if request.menu{
            detailsString.append("menu,")
        }
        if request.dateClosed{
            detailsString.append("date_closed,")
        }
        if request.photos{
            detailsString.append("photos,")
        }
        if request.tips{
            detailsString.append("tips,")
        }
        if request.tastes{
            detailsString.append("tastes,")
        }
        if request.features{
            detailsString.append("features,")
        }
        if request.storeID{
            //detailsString.append("store_id")
        }
        
        if detailsString.hasSuffix(",") {
            detailsString.removeLast()
        }
        
        let queryItem = URLQueryItem(name: "fields", value:detailsString)
        components?.queryItems = [queryItem]
        
        guard let url = components?.url else {
            throw PlaceSearchSessionError.UnsupportedRequest
        }
        
        return try await fetch(url: url, apiKey: self.foursquareApiKey)
    }
    
    public func photos(for fsqID:String) async throws -> Any {
        if searchSession == nil {
            searchSession = try await session()
        }
        
        var components = URLComponents(string:"\(PlaceSearchSession.serverUrl)\(PlaceSearchSession.placeDetailsAPIUrl)\(fsqID)\(PlaceSearchSession.placePhotosAPIUrl)")
        
        guard let url = components?.url else {
            throw PlaceSearchSessionError.UnsupportedRequest
        }
        
        return try await fetch(url: url, apiKey: self.foursquareApiKey)
    }
    
    public func tips(for fsqID:String) async throws -> Any {
        if searchSession == nil {
            searchSession = try await session()
        }
        
        var components = URLComponents(string:"\(PlaceSearchSession.serverUrl)\(PlaceSearchSession.placeDetailsAPIUrl)\(fsqID)\(PlaceSearchSession.placeTipsAPIUrl)")
        
        guard let url = components?.url else {
            throw PlaceSearchSessionError.UnsupportedRequest
        }
        
        return try await fetch(url: url, apiKey: self.foursquareApiKey)
    }
    
    
    internal func fetch(url:URL, apiKey:String) async throws ->Any {
        print("Requesting URL: \(url)")
        var request = URLRequest(url:url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        let responseAny:Any = try await withCheckedThrowingContinuation({checkedContinuation in
            let dataTask = searchSession?.dataTask(with: request, completionHandler: { data, response, error in
                if let e = error {
                    print(e.localizedDescription)
                    checkedContinuation.resume(throwing:e)
                } else {
                    if let d = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: d)
                            checkedContinuation.resume(returning:json)
                        } catch {
                            print(error.localizedDescription)
                            let returnedString = String(data: d, encoding: String.Encoding.utf8)
                            print(returnedString)
                            checkedContinuation.resume(throwing:error)
                        }
                    }
                }
            })
            
            dataTask?.resume()
        })
        
        return responseAny
    }
    
    
    public func session(service:String = PlaceSearchService.foursquare.rawValue) async throws -> URLSession {
        let task = Task.init { () -> Bool in
            let predicate = NSPredicate(format: "service == %@", service)
            let query = CKQuery(recordType: "KeyString", predicate: predicate)
            let operation = CKQueryOperation(query: query)
            operation.desiredKeys = ["value", "service"]
            operation.resultsLimit = 1
            operation.recordMatchedBlock = { [unowned self] recordId, result in
                do {
                    let record = try result.get()
                    if let apiKey = record["value"] as? String {
                        print("\(record["service"])")
                        print("Found API Key \(apiKey)")
                        self.foursquareApiKey = apiKey
                    } else {
                        print("Did not find API Key")
                    }
                } catch {
                    
                    print(error.localizedDescription)
                }
            }
            
            let success = try await withCheckedThrowingContinuation { checkedContinuation in
                operation.queryResultBlock = { result in
                    print(self.foursquareApiKey)
                    if self.foursquareApiKey == "" {
                        checkedContinuation.resume(with: .success(false))
                    } else {
                        checkedContinuation.resume(with: .success(true))
                    }
                }
                
                /*
                operation.queryCompletionBlock = { (result, error) in
                    if self.foursquareApiKey == "" {
                        checkedContinuation.resume(with: .success(false))
                    } else {
                        checkedContinuation.resume(with: .success(true))
                    }
                }
                 */
                
                operation.queuePriority = .veryHigh
                operation.qualityOfService = .userInteractive
  
                keysContainer.publicCloudDatabase.add(operation)
            }
            
            return success
        }
        
        
        let foundApiKey = try await task.value
        if foundApiKey {
            switch PlaceSearchService(rawValue:service) {
            case .foursquare:
                return configuredSession(for: service, key: self.foursquareApiKey)
            default:
                throw PlaceSearchSessionError.ServiceNotFound
            }
        } else {
            throw PlaceSearchSessionError.ServiceNotFound
        }
    }
}

private extension PlaceSearchSession {
    func configuredSession(for service:String, key:String)->URLSession {
        print("Beginning Place Search Session for \(service) with key \(key)")
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        return session
    }
}
