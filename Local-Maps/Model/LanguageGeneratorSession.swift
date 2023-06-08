import Foundation
import CloudKit

public enum LanguageGeneratorSessionError : Error {
    case ServiceNotFound
    case UnsupportedRequest
}

open class LanguageGeneratorSession : ObservableObject {
    private var openaiApiKey = ""
    private var searchSession:URLSession?
    let keysContainer = CKContainer(identifier:"iCloud.com.noisederived.No-Maps.Keys")
    static let serverUrl = "https://api.openai.com/v1/completions"
        
    init(){
        
    }
    
    init(apiKey: String = "", session: URLSession? = nil) {
        self.openaiApiKey = apiKey
        self.searchSession = session
        if let containerIdentifier = keysContainer.containerIdentifier {
            print(containerIdentifier)
        }
    }
    
    public func query(languageGeneratorRequest:LanguageGeneratorRequest) async throws->NSDictionary? {
        if searchSession == nil {
            searchSession = try await session()
        }
        let components = URLComponents(string: LanguageGeneratorSession.serverUrl)
        guard let url = components?.url else {
            throw LanguageGeneratorSessionError.ServiceNotFound
        }
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.openaiApiKey)", forHTTPHeaderField: "Authorization")
        
        var body:[String : Any] = ["model":languageGeneratorRequest.model, "prompt":languageGeneratorRequest.prompt, "max_tokens":languageGeneratorRequest.maxTokens,"temperature":languageGeneratorRequest.temperature]
        
        if let stop = languageGeneratorRequest.stop {
            body["stop"] = stop
        }
        
        if let user = languageGeneratorRequest.user {
            body["user"] = user
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        return try await fetch(urlRequest: request, apiKey: self.openaiApiKey) as? NSDictionary
    }
    
    internal func fetch(urlRequest:URLRequest, apiKey:String) async throws -> Any {
        print("Requesting URL: \(String(describing: urlRequest.url))")
        let responseAny:Any = try await withCheckedThrowingContinuation({checkedContinuation in
            let dataTask = searchSession?.dataTask(with: urlRequest, completionHandler: { data, response, error in
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
                            print(returnedString ?? "")
                            checkedContinuation.resume(throwing:error)
                        }
                    }
                }
            })
            
            dataTask?.resume()
        })
        
        return responseAny
    }
    
    
    public func session() async throws -> URLSession {
        let task = Task.init { () -> Bool in
            let predicate = NSPredicate(format: "service == %@", "openai")
            let query = CKQuery(recordType: "KeyString", predicate: predicate)
            let operation = CKQueryOperation(query: query)
            operation.desiredKeys = ["value", "service"]
            operation.resultsLimit = 1
            operation.recordMatchedBlock = { [unowned self] recordId, result in
                do {
                    let record = try result.get()
                    if let apiKey = record["value"] as? String {
                        print("\(String(describing: record["service"]))")
                        print("Found API Key \(apiKey)")
                        self.openaiApiKey = apiKey
                    } else {
                        print("Did not find API Key")
                    }
                } catch {
                    
                    print(error.localizedDescription)
                }
            }
            
            let success = try await withCheckedThrowingContinuation { checkedContinuation in
                operation.queryResultBlock = { result in
                    if self.openaiApiKey == "" {
                        checkedContinuation.resume(with: .success(false))
                    } else {
                        checkedContinuation.resume(with: .success(true))
                    }
                }
                
                keysContainer.publicCloudDatabase.add(operation)
            }
            
            return success
        }
        
        
        let foundApiKey = try await task.value
        if foundApiKey {
            return configuredSession( key: self.openaiApiKey)
        } else {
            throw LanguageGeneratorSessionError.ServiceNotFound
        }
    }
}

private extension LanguageGeneratorSession {
    func configuredSession(key:String)->URLSession {
        print("Beginning Language Generator Session with key \(key)")
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        return session
    }
}
