//
//  PlaceResponseFormatter.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/20/23.
//

import SwiftUI

public enum PlaceResponseFormatterError : Error {
    case InvalidRawResponseType
}

open class PlaceResponseFormatter {
    public class func placeSearchResponses(with response:Any) throws ->[PlaceSearchResponse] {
        var retVal = [PlaceSearchResponse]()
        
        guard let response = response as? NSDictionary else {
            throw PlaceResponseFormatterError.InvalidRawResponseType
        }

        if let results = response["results"] as? [NSDictionary] {
            
            for result in results {
                var ident = ""
                var name = ""
                var categories = [String]()
                var latitude:Double = 0
                var longitude:Double = 0
                var address = ""
                var addressExtended = ""
                var country = ""
                var dma = ""
                var formattedAddress = ""
                var locality = ""
                var postCode = ""
                var region = ""
                var chains = [String]()
                var link = ""
                var children = [String]()
                var parents = [String]()
                
                if let idString = result["fsq_id"] as? String {
                    ident = idString
                }
                
                if let nameString = result["name"] as? String {
                    name = nameString
                }
                if let categoriesArray = result["categories"] as? [NSDictionary] {
                    for categoryDict in categoriesArray {
                        if let name = categoryDict["name"] as? String {
                            categories.append(name)
                        }
                    }
                }
                
                if let geocodes = result["geocodes"] as? NSDictionary {
                    if let mainDict = geocodes["main"] as? NSDictionary {
                        if let latitudeNumber = mainDict["latitude"] as? NSNumber {
                            latitude = latitudeNumber.doubleValue
                        }
                        if let longitudeNumber = mainDict["longitude"] as? NSNumber {
                            longitude = longitudeNumber.doubleValue
                        }
                    }
                }
                
                if let locationDict = result["location"] as? NSDictionary {
                    if let addressString = locationDict["address"] as? String {
                        address = addressString
                    }
                    if let addressExtendedString = locationDict["address_extended"] as? String {
                        addressExtended = addressExtendedString
                    }
                    
                    if let countryString = locationDict["country"] as? String {
                        country = countryString
                    }
                    
                    if let dmaString = locationDict["dma"] as? String {
                        dma = dmaString
                    }
                    
                    if let formattedAddressString = locationDict["formatted_address"] as? String {
                        formattedAddress = formattedAddressString
                    }
                    
                    if let localityString = locationDict["locality"] as? String {
                        locality = localityString
                    }
                    
                    if let postCodeString = locationDict["postcode"] as? String {
                        postCode = postCodeString
                    }
                    
                    if let regionString = locationDict["region"] as? String {
                        region = regionString
                    }
                }
                
                if let chainsArray = response["chain"] as? [NSDictionary] {
                    for chainDict in chainsArray {
                        
                    }
                }
                
                if let linkString = response["link"] as? String {
                    link = linkString
                }
                
                if let relatedPlacesDict = response["related_places"] as? NSDictionary {
                    if let childrenArray = relatedPlacesDict["children"] as? [NSDictionary] {
                        for childDict in childrenArray {
                            if let ident = childDict["fsq_id"] as? String {
                                children.append(ident)
                            }
                        }
                    }
                }

                if ident.count > 0 {
                    let response = PlaceSearchResponse(fsqID: ident, name: name, categories: categories, latitude: latitude, longitude: longitude, address: address, addressExtended: addressExtended, country: country, dma: dma, formattedAddress: formattedAddress, locality: locality, postCode: postCode, region: region, chains: chains, link: link, childIDs: children, parentIDs: parents)
                    retVal.append(response)
                }
            }
        }

        return retVal
    }
    
    /*
     let ident:String
     let createdAt:String
     let height:Float
     let width:Float
     var aspectRatio:Float {
         get {
             return width/height
         }
     }
     let classifications:[String]
     let prefix:String
     let suffix:String
     */
    public class func placePhotoResponses(with response:Any, for placeID:String) throws ->[PlacePhotoResponse] {
        var retVal = [PlacePhotoResponse]()
        guard let response = response as? [NSDictionary] else {
            throw PlaceResponseFormatterError.InvalidRawResponseType
        }
        
        for photoDict in response {
            var ident = ""
            var createdAt = ""
            var height:Float = 1.0
            var width:Float = 0.0
            var classifications = [String]()
            var prefix = ""
            var suffix = ""
            if let idString = photoDict["id"] as? String {
                ident = idString
            }
            if let createdAtString = photoDict["created_at"] as? String {
                createdAt = createdAtString
            }
            if let heightNumber = photoDict["height"] as? NSNumber {
                height = heightNumber.floatValue
            }
            if let widthNumber = photoDict["width"] as? NSNumber {
                width = widthNumber.floatValue
            }
            if let classificationsArray = photoDict["classifications"] as? [String] {
                classifications = classificationsArray
            }
            if let prefixString = photoDict["prefix"] as? String {
                prefix = prefixString
            }
            if let suffixString = photoDict["suffix"] as? String {
                suffix = suffixString
            }
            
            let response = PlacePhotoResponse(placeIdent:placeID, ident: ident, createdAt: createdAt, height: height, width: width, classifications: classifications, prefix: prefix, suffix: suffix)
            retVal.append(response)
        }
        return retVal
    }
    
    public class func placeTipsResponses( with response:Any, for placeID:String) throws ->[PlaceTipsResponse] {
        var retVal = [PlaceTipsResponse]()
        
        guard let response = response as? [NSDictionary] else {
            throw PlaceResponseFormatterError.InvalidRawResponseType
        }
        
        for tipDict in response {
            var ident = ""
            var createdAt = ""
            var text = ""
            
            if let idString = tipDict["id"] as? String {
                ident = idString
            }
            
            if let createdAtString = tipDict["created_at"] as? String {
                createdAt = createdAtString
            }
            
            if let textString = tipDict["text"] as? String {
                text = textString
            }
            
            let response = PlaceTipsResponse(placeIdent:placeID, ident: ident, createdAt: createdAt, text: text)
            retVal.append(response)
        }
        return retVal
    }
    
    public class func firstChatResult(queryIntents:[AssistiveChatHostIntent])->ChatResult {
        if let lastIntent = queryIntents.last {
            switch lastIntent.intent {
            case .SearchDefault:
                let result = ChatResult(title:"Where can I find a place nearby?", backgroundColor: Color.orange, backgroundImageURL: nil)
                return result
            case .SaveDefault:
                let result = ChatResult(title:"Save a new place for later?", backgroundColor: Color.orange, backgroundImageURL: nil)
                return result
            case .TellDefault:
                let result = ChatResult(title:"Tell me about a new place?", backgroundColor: Color.orange, backgroundImageURL: nil)
                return result
            case .RecallDefault:
                let result = ChatResult(title:"What did I like about a place?", backgroundColor: Color.orange, backgroundImageURL: nil)
                return result
            default:
                break
            }
        }
        
        let result = ChatResult(title:"Where can I find a different place?", backgroundColor: Color.orange, backgroundImageURL: nil)
        return result
    }
    
    public class func placeChatResults(for place:PlaceSearchResponse, photos:[PlacePhotoResponse], resize:CGSize? = nil, queryIntents:[AssistiveChatHostIntent]? = nil)->[ChatResult] {
        
        let tellChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "Tell me about \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
        }
        
        let saveChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "Save \(place.name) for later?", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
        }
        
        let recallChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "What did I like about \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
        }
        
        let searchChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "Where can I find \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
        }
        
        guard let queryIntents = queryIntents, queryIntents.count > 0, let lastIntent = queryIntents.last else {
            return [tellChatResult()]
        }
        
        let placeChatResult:()->[ChatResult] = {
            var placeResults = [ChatResult]()
            let placeResultDirections = PlaceResponseFormatter.imageChatResult(title: "How do I get to \(place.name)", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            let placeResultPhotos = PlaceResponseFormatter.imageChatResult(title: "Show me the photos for \(place.name)", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            let placeResultTips = PlaceResponseFormatter.imageChatResult(title: "What do people say about \(place.name)", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            let placeResultInstagram = PlaceResponseFormatter.imageChatResult(title: "What is \(place.name)'s Instagram account?", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            let placeResultOpenHours = PlaceResponseFormatter.imageChatResult(title: "When is \(place.name) open?", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            let placeResultBusyHours = PlaceResponseFormatter.imageChatResult(title: "When is it busy at \(place.name)?", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            let placeResultPopularity =  PlaceResponseFormatter.imageChatResult(title: "How popular is \(place.name)?", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            let placeResultCost = PlaceResponseFormatter.imageChatResult(title: "How much does \(place.name) cost?", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            let placeResultMenu = PlaceResponseFormatter.imageChatResult(title: "What's does \(place.name) have?", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            let placeResultPhone = PlaceResponseFormatter.imageChatResult(title: "What is \(place.name)'s phone number?", backgroundColor: Color.purple, backgroundImageUrl: nil, photos: photos, resize:resize)
            placeResults.append(contentsOf:[placeResultDirections,placeResultPhotos,placeResultPhone, placeResultTips, placeResultInstagram, placeResultOpenHours, placeResultBusyHours, placeResultPopularity, placeResultCost, placeResultMenu ])
            
            return placeResults
        }
        
        let placeDetailsChatResults:(AssistiveChatHost.Intent)->[ChatResult] = { (intent) in
            switch intent {
            case .PlaceDetailsDirections:
                let response = PlaceResponseFormatter.imageChatResult(title: "Show me the map to \(place.name)", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:0)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            case .PlaceDetailsPhotos:
                let response = PlaceResponseFormatter.imageChatResult(title: "Show me \(place.name)'s gallery", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:1)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            case .PlaceDetailsTips:
                let response = PlaceResponseFormatter.imageChatResult(title: "Give me a summary of \(place.name)'s reviews", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:2)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            case .PlaceDetailsInstagram:
                let response = PlaceResponseFormatter.imageChatResult(title: "Take me to \(place.name)'s Instagram", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:3)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            case .PlaceDetailsOpenHours:
                let response = PlaceResponseFormatter.imageChatResult(title: "\(place.name) is open from", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:4)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            case .PlaceDetailsBusyHours:
                let response = PlaceResponseFormatter.imageChatResult(title: "\(place.name) is busy from", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:5)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            case .PlaceDetailsPopularity:
                let response = PlaceResponseFormatter.imageChatResult(title: "\(place.name) is popular", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:6)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            case .PlaceDetailsCost:
                let response = PlaceResponseFormatter.imageChatResult(title: "\(place.name) is expensive", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:7)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            case .PlaceDetailsMenu:
                let response = PlaceResponseFormatter.imageChatResult(title: "Show me \(place.name)'s menu", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:8)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            case .PlaceDetailsPhone:
                let response = PlaceResponseFormatter.imageChatResult(title: "\(place.name) phone number is ", backgroundColor: Color.red, backgroundImageUrl: nil, photos: photos, resize: resize)
                var placeChatResults = placeChatResult()
                placeChatResults.remove(at:9)
                placeChatResults.insert(response, at: 0)
                return placeChatResults
            default:
                return [ChatResult]()
            }
        }
        
        switch lastIntent.intent {
        case .TellDefault:
            return [tellChatResult()]
        case .SaveDefault:
            return [saveChatResult()]
        case .RecallDefault:
            return [recallChatResult()]
        case .SearchDefault:
            return [searchChatResult()]
        case .SearchPlace:
            fallthrough
        case .SavePlace:
            fallthrough
        case .TellPlace:
            fallthrough
        case .RecallPlace:
            return placeChatResult()
        case .PlaceDetailsDirections, .PlaceDetailsPhotos, .PlaceDetailsPhone, .PlaceDetailsTips, .PlaceDetailsMenu, .PlaceDetailsCost, .PlaceDetailsInstagram, .PlaceDetailsOpenHours, .PlaceDetailsPopularity, .PlaceDetailsBusyHours:
            return placeDetailsChatResults(lastIntent.intent)
        case .Unsupported:
            return [ChatResult]()
        }
    }
    
    public class func imageChatResult(title:String, backgroundColor:Color, backgroundImageUrl:URL?, photos:[PlacePhotoResponse],resize:CGSize? = nil )->ChatResult {
        let result = ChatResult(title:title, backgroundColor: backgroundColor, backgroundImageURL: backgroundImageUrl)
        
        var imageIdent = photos.first?.ident
        
        guard imageIdent != nil, var minAspectRatio = photos.first?.aspectRatio else {
            return result
        }
        
        for photo in photos {
            if photo.aspectRatio > minAspectRatio {
                imageIdent = photo.ident
            }
        }
        
        let widestImage = photos.first { response in
            return response.ident == imageIdent
        }
        
        guard let widestImage = widestImage else {
            return result
        }
        
        let imageResult = ChatResult(title: result.title, backgroundColor: result.backgroundColor, backgroundImageURL:  widestImage.photoUrl(resize:resize))
        
        return imageResult
    }
}
