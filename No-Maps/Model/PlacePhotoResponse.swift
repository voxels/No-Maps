//
//  PlacePhotoResponse.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/20/23.
//

import Foundation

public struct PlacePhotoResponse {
    let placeIdent:String
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
    
    func photoUrl(resize:CGSize? = nil) ->URL? {
        
        guard let resize = resize else {
            return URL(string:"\(prefix)\(Int(floor(width)))x\(Int(floor(height)))\(suffix)")
        }
        
        return URL(string:"\(prefix)\(Int(floor(resize.width)))x\(Int(floor(resize.height)))\(suffix)")
    }
}
