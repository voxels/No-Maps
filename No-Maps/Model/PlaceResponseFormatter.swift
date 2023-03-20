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
    
    public class func chatResult(for place:PlaceSearchResponse, photos:[PlacePhotoResponse], resize:CGSize? = nil)->ChatResult {
        let result = ChatResult(title: place.name, backgroundColor: Color.red, backgroundImageURL: nil)
        
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
