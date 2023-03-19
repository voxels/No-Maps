//
//  No_MapsApp.swift
//  No-Maps
//
//  Created by Michael A Edgcumbe on 3/19/23.
//

import SwiftUI

@main
struct No_MapsApp: App {
    @StateObject var placeSearchSession:PlaceSearchSession = PlaceSearchSession()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(placeSearchSession)
        }
    }
}
