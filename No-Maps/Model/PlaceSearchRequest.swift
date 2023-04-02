//
//  PlaceSearchRequest.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/19/23.
//

import Foundation

public struct PlaceSearchRequest {
    let query:String
    let ll:String?
    var radius:Int = 250
    let categories:String?
    let fields:String?
    var minPrice:Int = 1
    var maxPrice:Int = 4
    let openNow:Bool
    let nearLocation:String?
}
