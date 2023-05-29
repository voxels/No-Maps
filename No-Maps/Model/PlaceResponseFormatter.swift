//
//  PlaceResponseFormatter.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/20/23.
//

import SwiftUI
import NaturalLanguage

public enum PlaceResponseFormatterError : Error {
    case InvalidRawResponseType
}

open class PlaceResponseFormatter {
    public class func autocompletePlaceSearchResponses(with response:Any) throws ->[PlaceSearchResponse] {
        var retVal = [PlaceSearchResponse]()
        
        guard let response = response as? NSDictionary else {
            throw PlaceResponseFormatterError.InvalidRawResponseType
        }

        if let results = response["results"] as? [NSDictionary] {
            
            for resultDict in results {
                if let result = resultDict["place"] as? NSDictionary {
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
                    let chains = [String]()
                    var link = ""
                    var children = [String]()
                    let parents = [String]()
                    
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
                    
                    /*
                    if let chainsArray = response["chain"] as? [NSDictionary] {
                        for chainDict in chainsArray {
                            
                        }
                    }
                     */
                    
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
        }

        return retVal
    }
    
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
                let chains = [String]()
                var link = ""
                var children = [String]()
                let parents = [String]()
                
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
                
                /*
                if let chainsArray = response["chain"] as? [NSDictionary] {
                    for chainDict in chainsArray {
                        
                    }
                }
                 */
                
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
    
    public class func placeDetailsResponse(with response:Any, for placeSearchResponse:PlaceSearchResponse, placePhotosResponses:[PlacePhotoResponse]? = nil, placeTipsResponses:[PlaceTipsResponse]? = nil) throws ->PlaceDetailsResponse {
        guard let response = response as? NSDictionary else {
            throw PlaceResponseFormatterError.InvalidRawResponseType
        }
        
        let searchResponse = placeSearchResponse
        let photoResponses = placePhotosResponses
        let tipsResponses = placeTipsResponses
        var description:String? = nil
        
        if let rawDescription = response["description"] as? String {
            print(rawDescription)
            description = rawDescription
        }
        
        var tel:String? = nil
        if let rawTel = response["tel"] as? String {
            tel = rawTel
        }
        
        var fax:String? = nil
        if let rawFax = response["fax"] as? String {
            fax = rawFax
        }
        
        var email:String? = nil
        if let rawEmail = response["email"] as? String {
            email = rawEmail
        }

        var website:String? = nil
        if let rawWebsite = response["website"] as? String {
            website = rawWebsite
        }

        var socialMedia:[String:String]? = nil
        if let rawSocialMedia = response["social_media"] as? [String:String] {
            socialMedia = rawSocialMedia
        }
        
        var verified:Bool? = nil
        verified = false
        
        var hours:String? = nil
        var openNow:Bool? = nil
        if let hoursDict = response["hours"] as? NSDictionary {
            if let hoursDisplayText = hoursDict["display"] as? String {
                hours = hoursDisplayText
            }
            if let rawOpen = hoursDict["open_now"] as? Int {
                if rawOpen == 1 {
                    openNow = true
                } else {
                    openNow = false
                }
            }
        }
        
        var hoursPopular:[[String:Int]]? = nil
        if let rawHoursPopular = response["hours_popular"] as? [[String:Int]] {
            hoursPopular = rawHoursPopular
        }
        var rating:Float = 0
        if let rawRating = response["rating"] as? Double {
            rating = Float(rawRating)
        }
        var stats:Bool? = nil
        stats = false
        var popularity:Float = 0
        if let rawPopularity = response["popularity"] as? Double {
            popularity = Float(rawPopularity)
        }
        var price:Int? = nil
        if let rawPrice = response["price"] as? Int {
            price = rawPrice
        }
        var menu:AnyObject? = nil
        if let rawMenu = response["menu"] as? AnyObject {
            menu = rawMenu
        }
        var dateClosed:String? = nil
        if let rawDateClosed = response["date_closed"] as? String {
            dateClosed = rawDateClosed
        }
        
        var tastes:[String]? = nil
        if let rawTastes = response["tastes"] as? [String] {
            tastes = rawTastes
        }
        
        let features:[String]? = nil        
        
        return PlaceDetailsResponse(searchResponse: searchResponse, photoResponses: photoResponses, tipsResponses: tipsResponses, description: description, tel: tel, fax: fax, email: email, website: website, socialMedia: socialMedia, verified: verified, hours: hours, openNow: openNow, hoursPopular: hoursPopular, rating: rating, stats: stats, popularity: popularity, price: price, menu: menu, dateClosed: dateClosed, tastes: tastes, features: features)
        
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
                let result = ChatResult(title:"Tell me about", backgroundColor: Color.green, backgroundImageURL: nil, placeResponse: nil, placeDetailsResponse: nil)
                return result
            case .SaveDefault:
                let result = ChatResult(title:"Save a new place for later?", backgroundColor: Color.orange, backgroundImageURL: nil, placeResponse: nil, placeDetailsResponse: nil)
                return result
            case .TellDefault:
                let result = ChatResult(title:"Where can I find", backgroundColor: Color.green, backgroundImageURL: nil, placeResponse: nil, placeDetailsResponse: nil)
                return result
            case .RecallDefault:
                let result = ChatResult(title:"What did I like about a place?", backgroundColor: Color.orange, backgroundImageURL: nil, placeResponse: nil, placeDetailsResponse: nil)
                return result
            default:
                break
            }
        }
        
        let result = ChatResult(title:"Ask a different question", backgroundColor: Color.red, backgroundImageURL: nil, placeResponse: nil, placeDetailsResponse: nil)
        return result
    }
    
    public class func placeDetailsChatResults(for place:PlaceSearchResponse, details:PlaceDetailsResponse, photos:[PlacePhotoResponse], tips:[PlaceTipsResponse],  results:[PlaceSearchResponse], resize:CGSize? = nil, queryIntents:[AssistiveChatHostIntent]? = nil )->[ChatResult] {
        print("Showing details chat results for \(place.name) with intent:\(String(describing: queryIntents?.last?.intent))")
        let usedPhotoIDs = [String]()
        
        let placeDetailsChatResultZeroIntent:()->[ChatResult] = {
            var placeResults = [ChatResult]()
            if let description = details.description {
                let placeResultDescription = PlaceResponseFormatter.imageChatResult(title: description, backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                placeResults.append(placeResultDescription)
            }
            
            let placeResultAddress = PlaceResponseFormatter.imageChatResult(title: details.searchResponse.address, backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
            placeResults.append(placeResultAddress)
            
            if let tel = details.tel {
                let placeResultTel = PlaceResponseFormatter.imageChatResult(title: tel, backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                placeResults.append(placeResultTel)
            }
            
            if let price = details.price {
                let placeResultPrice = PlaceResponseFormatter.imageChatResult(title: "\(price)", backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs),resize: resize)
                placeResults.append(placeResultPrice)
            }

            let placeResultDirections = PlaceResponseFormatter.imageChatResult(title: "How do I get to \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
            placeResults.append(placeResultDirections)
            if photos.count > 0{
                let placeResultPhotos = PlaceResponseFormatter.imageChatResult(title: "Show me the photos for \(place.name)", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultPhotos)
            }
            if details.tipsResponses != nil {
                let placeResultTips = PlaceResponseFormatter.imageChatResult(title: "What do people say about \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: nil, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs),resize:resize)
                placeResults.append(placeResultTips)
            }
            if let socialMedia = details.socialMedia, socialMedia.keys.contains("instagram"){
                let placeResultInstagram = PlaceResponseFormatter.imageChatResult(title: "Show me \(place.name)'s Instagram account", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultInstagram)
            }
            if let _ = details.hours {
                let placeResultOpenHours = PlaceResponseFormatter.imageChatResult(title: "When is \(place.name) open?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultOpenHours)

            }
            if let _ = details.hoursPopular {
                let placeResultBusyHours = PlaceResponseFormatter.imageChatResult(title: "When is it busy at \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultBusyHours)
            }
            if details.popularity > 0 {
                let placeResultPopularity =  PlaceResponseFormatter.imageChatResult(title: "How popular is \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultPopularity)
            }

            if let _ = details.price{
                let placeResultCost = PlaceResponseFormatter.imageChatResult(title: "How much does \(place.name) cost?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultCost)
            }
            if let _ = details.menu  as? NSDictionary {
                let placeResultMenu = PlaceResponseFormatter.imageChatResult(title: "What's does \(place.name) have?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultMenu)
            }
            
            if let _ = details.tel {
                let placeResultPhone = PlaceResponseFormatter.imageChatResult(title: "Call \(place.name)", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultPhone)
            }
            
            return placeResults
        }

        
        let placeDetailsChatResults:(AssistiveChatHostIntent)->[ChatResult] = { (intent) in
            var detailsResults = [ChatResult]()
            
            var placeResults = [ChatResult]()
            if let description = details.description {
                let placeResultDescription = PlaceResponseFormatter.imageChatResult(title: description, backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                placeResults.append(placeResultDescription)
            }
            
            let placeResultAddress = PlaceResponseFormatter.imageChatResult(title: details.searchResponse.address, backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
            placeResults.append(placeResultAddress)
            
            if let tel = details.tel {
                let placeResultTel = PlaceResponseFormatter.imageChatResult(title: tel, backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                placeResults.append(placeResultTel)
            }
            
            if let price = details.price {
                let placeResultPrice = PlaceResponseFormatter.imageChatResult(title: "\(price)", backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs),resize: resize)
                placeResults.append(placeResultPrice)
            }
            
            var intentResult:ChatResult?
            
            switch intent.intent {
            case .PlaceDetailsDirections:
                let response = PlaceResponseFormatter.imageChatResult(title: "How do I get to to \(place.name)", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                intentResult = response
            case .PlaceDetailsPhotos:
                let response = PlaceResponseFormatter.imageChatResult(title: "Show me \(place.name)'s gallery", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                intentResult = response
            case .PlaceDetailsTips:
                let response = PlaceResponseFormatter.imageChatResult(title: "Give me a summary of \(place.name)'s reviews", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                intentResult = response
            case .PlaceDetailsInstagram:
                let response = PlaceResponseFormatter.imageChatResult(title: "Show me \(place.name)'s Instagram account", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                intentResult = response
            case .PlaceDetailsOpenHours:
                if let hours = details.hours {
                    let response = PlaceResponseFormatter.imageChatResult(title:hours, backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                    intentResult = response
                }
            case .PlaceDetailsBusyHours:
                let placeResultBusyHours = PlaceResponseFormatter.imageChatResult(title: "When is it busy at \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                intentResult = placeResultBusyHours
            case .PlaceDetailsPopularity:
                let response = PlaceResponseFormatter.imageChatResult(title: "\(place.name) popularity is \(details.popularity)", backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                intentResult = response
            case .PlaceDetailsCost:
                if let price = details.price {
                    let response = PlaceResponseFormatter.imageChatResult(title: "\(price)", backgroundColor: Color.black, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                    intentResult = response
                }
            case .PlaceDetailsMenu:
                let response = PlaceResponseFormatter.imageChatResult(title: "Show me \(place.name)'s menu", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
                intentResult = response
            case .PlaceDetailsPhone:
                let response = PlaceResponseFormatter.imageChatResult(title: "Call \(place.name)", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs),resize: resize)
                intentResult = response
            default:
                break
            }
            
            detailsResults.append(contentsOf: placeResults)
            
            if let result = intentResult {
                detailsResults.append(result)
            }
            
            return detailsResults
        }
        
        let placeChatResults:(AssistiveChatHostIntent)->[ChatResult] = { lastIntent in
            var placeResults = [ChatResult]()
            let placeResultDirections = PlaceResponseFormatter.imageChatResult(title: "How do I get to \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
            if lastIntent.intent != .PlaceDetailsDirections {
                placeResults.append(placeResultDirections)
            }
            if photos.count > 0, lastIntent.intent != .PlaceDetailsPhotos {
                let placeResultPhotos = PlaceResponseFormatter.imageChatResult(title: "Show me the photos for \(place.name)", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultPhotos)
            }
            if details.tipsResponses != nil, lastIntent.intent != .PlaceDetailsTips {
                let placeResultTips = PlaceResponseFormatter.imageChatResult(title: "What do people say about \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs),resize:resize)
                placeResults.append(placeResultTips)
            }
            if ((details.socialMedia?.keys.contains("instagram")) != nil), lastIntent.intent != .PlaceDetailsInstagram {
                let placeResultInstagram = PlaceResponseFormatter.imageChatResult(title: "Show me \(place.name)'s Instagram account", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultInstagram)
            }
            if let _ = details.hours, lastIntent.intent != .PlaceDetailsOpenHours {
                let placeResultOpenHours = PlaceResponseFormatter.imageChatResult(title: "When is \(place.name) open?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultOpenHours)

            }
            if let _ = details.hoursPopular, lastIntent.intent != .PlaceDetailsBusyHours {
                let placeResultBusyHours = PlaceResponseFormatter.imageChatResult(title: "When is it busy at \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultBusyHours)
            }
            if lastIntent.intent != .PlaceDetailsPopularity, details.popularity > 0 {
                let placeResultPopularity =  PlaceResponseFormatter.imageChatResult(title: "How popular is \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultPopularity)
            }
            if let _ = details.price, lastIntent.intent != .PlaceDetailsCost {
                let placeResultCost = PlaceResponseFormatter.imageChatResult(title: "How much does \(place.name) cost?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultCost)
            }
            if let _ = details.menu as? NSDictionary, lastIntent.intent != .PlaceDetailsMenu {
                let placeResultMenu = PlaceResponseFormatter.imageChatResult(title: "What's does \(place.name) have?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultMenu)
            }
            if let _ = details.tel, lastIntent.intent != .PlaceDetailsPhone {
                let placeResultPhone = PlaceResponseFormatter.imageChatResult(title: "What is \(place.name)'s phone number?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
                placeResults.append(placeResultPhone)
            }
            
            return placeResults
        }
        
        if let lastIntent = queryIntents?.last {
            let detailsChatResults = placeDetailsChatResults(lastIntent)
            let placeChatResults = placeChatResults(lastIntent)
            var allResults = detailsChatResults
            allResults.append(contentsOf: placeChatResults)
            return allResults
        } else {
            let detailsChatResults = placeDetailsChatResultZeroIntent()
            let allResults = detailsChatResults
            return allResults
        }
    }
    
    public class func placeChatResults(for place:PlaceSearchResponse, details:PlaceDetailsResponse? = nil, resize:CGSize? = nil, queryIntents:[AssistiveChatHostIntent]? = nil)->[ChatResult] {
        let photos = details?.photoResponses ?? [PlacePhotoResponse]()
        
        let usedPhotoIDs = [String]()
        
        let tellChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "Tell me about \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: nil, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
        }
        
        let saveChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "Save \(place.name) for later?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: nil, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
        }
        
        let recallChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "What did I like about \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: nil, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
        }
        
        let searchChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "Where can I find \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: nil, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize: resize)
        }
        
        guard let queryIntents = queryIntents, queryIntents.count > 0, let lastIntent = queryIntents.last else {
            return [tellChatResult()]
        }
        
        let placeChatResult:()->[ChatResult] = {
            var placeResults = [ChatResult]()
            let placeResultDirections = PlaceResponseFormatter.imageChatResult(title: "How do I get to \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: nil, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
            let placeResultPhone = PlaceResponseFormatter.imageChatResult(title: "What is \(place.name)'s phone number?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: nil, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs), resize:resize)
            placeResults.append(contentsOf:[placeResultDirections,placeResultPhone])
            
            return placeResults
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
        case .SearchQuery:
            return [tellChatResult()]
        case .SearchPlace:
            return [tellChatResult()]
        case .SavePlace:
            fallthrough
        case .TellPlace:
            fallthrough
        case .RecallPlace:
            fallthrough
        case .TellQuery, .PlaceDetailsDirections, .PlaceDetailsPhotos, .PlaceDetailsPhone, .PlaceDetailsTips, .PlaceDetailsMenu, .PlaceDetailsCost, .PlaceDetailsInstagram, .PlaceDetailsOpenHours, .PlaceDetailsPopularity, .PlaceDetailsBusyHours, .OpenDefault, .ShareResult:
            return placeChatResult()
        case .Unsupported:
            return [ChatResult]()
        }
    }
    
    public class func imageChatResult(title:String, backgroundColor:Color, backgroundImageUrl:URL?, placeResponse:PlaceSearchResponse?, placeDetailsResponse:PlaceDetailsResponse?, photoResponse:PlacePhotoResponse? = nil, resize:CGSize? = nil )->ChatResult {
        let result = ChatResult(title:title, backgroundColor: backgroundColor, backgroundImageURL: backgroundImageUrl, placeResponse: placeResponse, placeDetailsResponse:placeDetailsResponse)
        
        if backgroundImageUrl != nil {
            return result
        }
        
        guard let photo = photoResponse else {
            return result
        }
        
        let imageResult = ChatResult(title: result.title, backgroundColor: result.backgroundColor, backgroundImageURL:  photo.photoUrl(resize:resize), placeResponse: placeResponse, placeDetailsResponse: placeDetailsResponse)
        
        return imageResult
    }
    
    public class func unusedPhoto(in responses:[PlacePhotoResponse], with usedPhotoIDs:[String])->PlacePhotoResponse? {
        let remainingPhotos = responses.filter { response in
            return !usedPhotoIDs.contains(response.ident)
        }
        
        return remainingPhotos.first
    }
}
