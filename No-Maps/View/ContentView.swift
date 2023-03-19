//
//  ContentView.swift
//  No-Maps
//
//  Created by Michael A Edgcumbe on 3/19/23.
//

import SwiftUI

struct ContentView: View {
    @State private var messagesViewHeight:CGFloat = 253

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle().ignoresSafeArea(.all)
                ChatResultView(messagesViewHeight: $messagesViewHeight)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
