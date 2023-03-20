//
//  ChatResult.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/19/23.
//

import SwiftUI

public struct ChatResult : Identifiable, Equatable {
    public let id = UUID()
    let title:String
    let backgroundColor:Color
    let backgroundImageURL:URL?
}
