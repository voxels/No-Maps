//
//  ChatResultView.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/19/23.
//

import SwiftUI

struct ChatResultView : View {
    
    @EnvironmentObject var placeSearchSession:PlaceSearchSession
    @EnvironmentObject var locationProvider:LocationProvider

    @Binding public var messagesViewHeight:CGFloat
    @State private var interitemDistance:CGFloat = 8.0
    @State private var scrollViewPadding:CGFloat = 20.0
    @State private var model:[ChatResult] = [
        ChatResult(title: "Place 1", backgroundColor: Color.red, backgroundImage: nil),
        ChatResult(title: "I like this place", backgroundColor: Color.blue, backgroundImage: nil),
        ChatResult(title: "Place 2", backgroundColor: Color.red, backgroundImage: nil),
        ChatResult(title: "Where can I find", backgroundColor: Color.blue, backgroundImage: nil),
        ChatResult(title: "Place 3", backgroundColor: Color.red, backgroundImage: nil),
        ChatResult(title: "Where did I like", backgroundColor: Color.blue, backgroundImage: nil),
        ChatResult(title: "Place 4", backgroundColor: Color.red, backgroundImage: nil),
        ChatResult(title: "Place 5", backgroundColor: Color.red, backgroundImage: nil)
    ]
    
    var body: some View {
        VStack{
            Spacer()
            ZStack {
                Rectangle().foregroundColor(.white).frame(height:$messagesViewHeight.wrappedValue)
                VStack {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            let columns = createColumns(from: model)
                            ForEach(columns, id:\.0.id) { column in
                                VStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 16.0).fill(column.0.backgroundColor).frame(width:(UIScreen.main.bounds.width - scrollViewPadding - interitemDistance) / 2.0, height:($messagesViewHeight.wrappedValue) / 2.0 - interitemDistance - scrollViewPadding, alignment: .center )
                                        let showBackgroundImage = column.0.backgroundImage != nil
                                        VStack{
                                            HStack{
                                                showBackgroundImage ?                      Text(column.0.title).multilineTextAlignment(.leading).font(.system(.headline)).foregroundColor(.white) : Text(column.0.title).multilineTextAlignment(.center).font(.system(.headline)).foregroundColor(.white)
                                                if showBackgroundImage {
                                                    Spacer()
                                                }
                                            }.padding(8.0)
                                            Spacer()
                                        }
                                    }
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16.0).fill(column.1.backgroundColor).frame(width:(UIScreen.main.bounds.width - scrollViewPadding - interitemDistance) / 2.0, height:($messagesViewHeight.wrappedValue) / 2.0 - interitemDistance - scrollViewPadding, alignment: .center )
                                        let showBackgroundImage = column.1.backgroundImage != nil
                                        VStack{
                                            HStack{
                                                showBackgroundImage ?                      Text(column.1.title).multilineTextAlignment(.leading).font(.system(.headline)).foregroundColor(.white) : Text(column.1.title).multilineTextAlignment(.center).font(.system(.headline)).foregroundColor(.white)
                                                if showBackgroundImage {
                                                    Spacer()
                                                }
                                            }.padding(8.0)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }.padding(scrollViewPadding)
                    }
                }.frame(height:messagesViewHeight)
            }
        }.onAppear {
            locationProvider.authorize()
            let location = locationProvider.currentLocation()
            let task = Task.init {
                do {
                    var locationString = ""
                    if let l = location {
                        locationString = "\(l.coordinate.latitude),\(l.coordinate.longitude)"
                        print("Fetching places with location string: \(locationString)")
                    }
                    let request = PlaceSearchRequest(query: "", ll: locationString, categories: nil, fields: nil, openNow: true, nearLocation: nil)
                    let placeSearchResponse = try await placeSearchSession.query(request:request)
                    
                }
                catch {
                    
                }
            }
        }
    }
    
    func createColumns(from
                       results:[ChatResult])->[(ChatResult, ChatResult)] {
        var firstResult:ChatResult = model[0]
        var secondResult:ChatResult = model[1]
        var columns:[(ChatResult, ChatResult)] = [(ChatResult, ChatResult)]()
        
        for index in 0..<model.count {
            let verticalPosition = index % 2
            let result = model[index]
            switch verticalPosition {
            case 1:
                secondResult = result
                columns.append((firstResult, secondResult))
            default:
                firstResult = result            }
        }
        
        return columns
    }
}

struct ChatResultView_Previews: PreviewProvider {
    static var previews: some View {
        let height:CGFloat = 253.0
        ChatResultView(messagesViewHeight:.constant(height))
    }
}
