//
//  PlaceResponseFormatter.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/20/23.
//

import SwiftUI
import NaturalLanguage
import CoreLocation

public enum PlaceResponseFormatterError : Error {
    case InvalidRawResponseType
}

open class PlaceResponseFormatter {
    public class func autocompletePlaceSearchResponses(with response:NSDictionary) throws ->[PlaceSearchResponse] {
        var retVal = [PlaceSearchResponse]()
        
        guard response.allKeys.count > 0 else {
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
    
    public class func placeSearchResponses(with response:Any, nearLocation:CLLocation) throws ->[PlaceSearchResponse] {
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
        
        let sortedPlaceSearchResponses = retVal.sorted(by: { firstLocation, checkLocation in
            let firstLocationCoordinate = CLLocation(latitude: firstLocation.latitude, longitude: firstLocation.longitude)
            let checkLocationCoordinate = CLLocation(latitude: checkLocation.latitude, longitude: checkLocation.longitude)
            
            return firstLocationCoordinate.distance(from: nearLocation) < checkLocationCoordinate.distance(from: nearLocation)
        })
        
        return sortedPlaceSearchResponses
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
        
        if let response = response as? NSDictionary, response.allKeys.count == 0 {
            return retVal
        }
        
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
        
        if let response = response as? NSDictionary, response.allKeys.count == 0 {
            return retVal
        }
        
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
    
    public class func placeDetailsChatResults(for place:PlaceSearchResponse, details:PlaceDetailsResponse, photos:[PlacePhotoResponse], tips:[PlaceTipsResponse],  results:[PlaceSearchResponse] )->[ChatResult] {
        print("Showing details chat results for \(place.name))")
        let usedPhotoIDs = [String]()
        var placeResults = [ChatResult]()
        if let description = details.description {
            let placeResultDescription = PlaceResponseFormatter.imageChatResult(title:"Share:  \(description)", backgroundColor: Color.accentColor, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultDescription)
        }
        
        let placeResultAddress = PlaceResponseFormatter.imageChatResult(title: "Share the address:\n\(details.searchResponse.address)", backgroundColor: Color.accentColor, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
        placeResults.append(placeResultAddress)
        
        if let tel = details.tel {
            let placeResultTel = PlaceResponseFormatter.imageChatResult(title: "Share the phone number: \(tel)" , backgroundColor: Color.accentColor, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultTel)
        }
        
        if let price = details.price {
            var description = "Share the price: "
            switch price {
            case 1:
                description.append("Cheap")
            case 2:
                description.append("Moderately Priced")
            case 3:
                description.append("Expensive")
            case 4:
                description.append("Very Expensive")
            default:
                description = "Price Not Listed"
            }
            
            let placeResultPrice = PlaceResponseFormatter.imageChatResult(title: description , backgroundColor: Color.accentColor, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultPrice)
        }
        
        let placeResultDirections = PlaceResponseFormatter.imageChatResult(title: "How do I get to \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
        placeResults.append(placeResultDirections)
        if photos.count > 0{
            let placeResultPhotos = PlaceResponseFormatter.imageChatResult(title: "Show me the photos for \(place.name)", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultPhotos)
        }
        if details.tipsResponses != nil {
            let placeResultTips = PlaceResponseFormatter.imageChatResult(title: "What do people say about \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: nil, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultTips)
        }
        if let socialMedia = details.socialMedia, socialMedia.keys.contains("instagram"){
            let placeResultInstagram = PlaceResponseFormatter.imageChatResult(title: "Show me \(place.name)'s Instagram account", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultInstagram)
        }
        if let _ = details.hours {
            let placeResultOpenHours = PlaceResponseFormatter.imageChatResult(title: "When is \(place.name) open?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultOpenHours)
            
        }
        if let _ = details.hoursPopular {
            let placeResultBusyHours = PlaceResponseFormatter.imageChatResult(title: "When is it busy at \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultBusyHours)
        }
        if details.popularity > 0 {
            let placeResultPopularity =  PlaceResponseFormatter.imageChatResult(title: "How popular is \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultPopularity)
        }
        
        if let _ = details.menu  as? NSDictionary {
            let placeResultMenu = PlaceResponseFormatter.imageChatResult(title: "What's does \(place.name) have?", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultMenu)
        }
        
        if let _ = details.tel {
            let placeResultPhone = PlaceResponseFormatter.imageChatResult(title: "Call \(place.name)", backgroundColor: Color.red, backgroundImageUrl: nil, placeResponse: place, placeDetailsResponse: details, photoResponse: PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
            placeResults.append(placeResultPhone)
        }
        
        return placeResults
    }
    
    public class func placeChatResults(for intent:AssistiveChatHostIntent, place:PlaceSearchResponse, details:PlaceDetailsResponse?)->[ChatResult] {
        let photos = details?.photoResponses ?? [PlacePhotoResponse]()
        
        let usedPhotoIDs = [String]()
        
        let tellChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "Tell me about \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
        }
        
        let searchChatResult:()->ChatResult = {
            return PlaceResponseFormatter.imageChatResult(title: "Where can I find \(place.name)?", backgroundColor: Color.red, backgroundImageUrl: nil,placeResponse: place, placeDetailsResponse: details, photoResponse:PlaceResponseFormatter.unusedPhoto(in: photos, with: usedPhotoIDs))
        }
        
        switch intent.intent {
        case .TellDefault:
            return [tellChatResult()]
        case .SearchDefault:
            return [searchChatResult()]
        case .SearchQuery:
            return [tellChatResult()]
        default:
            return [ChatResult]()
        }
    }
    
    public class func imageChatResult(title:String, backgroundColor:Color, backgroundImageUrl:URL?, placeResponse:PlaceSearchResponse?, placeDetailsResponse:PlaceDetailsResponse?, photoResponse:PlacePhotoResponse? = nil)->ChatResult {
        let result = ChatResult(title:title, backgroundColor: backgroundColor, backgroundImageURL: backgroundImageUrl, placeResponse: placeResponse, placeDetailsResponse:placeDetailsResponse)
        
        if backgroundImageUrl != nil {
            return result
        }
        
        guard let photo = photoResponse else {
            return result
        }
        
        let imageResult = ChatResult(title: result.title, backgroundColor: result.backgroundColor, backgroundImageURL:  photo.photoUrl(), placeResponse: placeResponse, placeDetailsResponse: placeDetailsResponse)
        
        return imageResult
    }
    
    public class func unusedPhoto(in responses:[PlacePhotoResponse], with usedPhotoIDs:[String])->PlacePhotoResponse? {
        let remainingPhotos = responses.filter { response in
            return !usedPhotoIDs.contains(response.ident)
        }
        
        return remainingPhotos.first
    }
}
