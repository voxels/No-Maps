//
//  ChatResultView.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/19/23.
//

import SwiftUI
import CoreLocation

struct ChatResultView : View {
    @StateObject public var chatHost:AssistiveChatHost
    @StateObject public var model:ChatResultViewModel
    
    let locationAuthorizedPublisher = NotificationCenter.default.publisher(for: Notification.Name("LocationProviderAuthorized"))
    
    let locationDeniedPublisher = NotificationCenter.default.publisher(for: Notification.Name("LocationProviderDenied"))
    
    var body: some View {
        ChatResultViewHorizontalStack(chatHost: chatHost, model: model).onAppear {
            model.authorizeLocationProvider()
            if let location = model.locationProvider.currentLocation() {
                model.refreshModel( queryIntents: chatHost.queryIntentParameters.queryIntents, nearLocation:location)
            }
        }.padding(8)
            .onReceive(locationAuthorizedPublisher) { output in
                if let location = model.locationProvider.currentLocation() {
                    model.refreshModel( queryIntents: chatHost.queryIntentParameters.queryIntents, nearLocation:location)
                }
            }
            .onReceive(locationDeniedPublisher) { output in
                // Show Alert Message
            }
    }
    
    func refreshModel(with location:CLLocation) {
        
    }
}

struct ChatResultViewHorizontalStack : View  {
    @ObservedObject public var chatHost:AssistiveChatHost
    @ObservedObject public var model:ChatResultViewModel
    private var firstChatResult:ChatResult? {
        get {
            return model.results.first
        }
    }
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(model.results) { result in
                        Text(result.title)
                            .font(.system(.headline))
                            .foregroundColor(Color(UIColor.label))
                            .padding(8)
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth:UIScreen.main.bounds.size.width * 2.0 / 3.0, minHeight:64, maxHeight:.infinity)
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .background(in: Capsule(style: .circular)).backgroundStyle(result.backgroundColor)
                            .onTapGesture {
                                chatHost.didTap(chatResult: result)
                            }.id(result)
                    }
                }
            }
            .onChange(of: model.results, perform: { newValue in
                if let first = firstChatResult {
                    value.scrollTo(first, anchor:.leading)
                }
            })
        }
    }
}

struct ChatResultView_Previews: PreviewProvider {
    static var previews: some View {
        let chatHost = AssistiveChatHost()
        let model = ChatResultViewModel()
        ChatResultView(chatHost:chatHost, model: model)
    }
}
