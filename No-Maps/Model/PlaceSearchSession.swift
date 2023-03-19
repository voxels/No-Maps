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
}

open class PlaceSearchSession : ObservableObject {
    private var foursquareApiKey = ""
    private var foursquareSession:URLSession?
    let container = CKContainer(identifier:"iCloud.com.noisederived.No-Maps.Keys")

    init(){
        
    }
    
    init(foursquareApiKey: String = "", foursquareSession: URLSession? = nil) {
        self.foursquareApiKey = foursquareApiKey
        self.foursquareSession = foursquareSession
        if let containerIdentifier = container.containerIdentifier {
            print(containerIdentifier)
        }
    }
    
    public func query(request:PlaceSearchRequest) async throws {
        if foursquareSession == nil {
            foursquareSession = try await session()
        }
    }
    
    public enum PlaceSearchService : String {
        case foursquare
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
                    if self.foursquareApiKey == "" {
                        checkedContinuation.resume(with: .success(false))
                    } else {
                        checkedContinuation.resume(with: .success(true))
                    }
                }
                
                container.publicCloudDatabase.add(operation)
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
