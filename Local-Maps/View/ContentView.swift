//
//  ContentView.swift
//  No-Maps
//
//  Created by Michael A Edgcumbe on 3/19/23.
//

import SwiftUI

struct ContentView: View {
    @State private var chatHost:AssistiveChatHost = AssistiveChatHost()
    @StateObject private var chatModel =  ChatResultViewModel()

    var body: some View {   
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Rectangle().ignoresSafeArea(.all)
                    ChatResultView(chatHost: self.chatHost, model: chatModel)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
