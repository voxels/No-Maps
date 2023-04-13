//
//  PlaceDetailsResponse.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 4/1/23.
//

import Foundation
public struct PlaceDetailsResponse  {
    let searchResponse:PlaceSearchResponse
    let photoResponses:[PlacePhotoResponse]?
    let tipsResponses:[PlaceTipsResponse]?
    let description:String?
    let tel:String?
    let fax:String?
    let email:String?
    let website:String?
    let socialMedia:[String:String]?
    let verified:Bool?
    let hours:String?
    let openNow:Bool?
    let hoursPopular:[[String:Int]]?
    let rating:Float
    let stats:Bool?
    let popularity:Float
    let price:String?
    let menu:AnyObject?
    let dateClosed:String?
    let tastes:[String]?
    let features:[String]?
    
    var fsqID:String {
        get {
            return searchResponse.fsqID
        }
    }

}
