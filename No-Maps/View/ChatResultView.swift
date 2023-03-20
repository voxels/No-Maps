//
//  ChatResultView.swift
//  No Maps
//
//  Created by Michael A Edgcumbe on 3/19/23.
//

import SwiftUI

struct ChatResultView : View {
    @Binding public var messagesViewHeight:CGFloat
    @State private var interitemDistance:CGFloat = 8.0
    @State private var scrollViewPadding:CGFloat = 8.0
    
    @StateObject private var model = ChatResultViewModel()
    
    var body: some View {
        VStack{
            Spacer()
            ZStack {
                Rectangle().foregroundColor(.white).frame(height:$messagesViewHeight.wrappedValue)
                VStack {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            let columns = createColumns(from: model.results)
                            ForEach(columns, id:\.0.id) { column in
                                Divider().padding(10)
                                VStack{
                                    Spacer()
                                    ZStack{
                                        let showBackgroundImage = column.0.backgroundImageURL != nil
                                        HStack{
                                            Spacer()
                                            showBackgroundImage ?                      Text(column.0.title).multilineTextAlignment(.center).font(.system(.headline)).foregroundColor(Color(UIColor.lightText)).padding(8).truncationMode(.tail).background(in: Capsule(style:.circular)).backgroundStyle(.purple).frame(maxWidth:(UIScreen.main.bounds.width - scrollViewPadding - interitemDistance) / 2.0): Text(column.0.title).multilineTextAlignment(.center).font(.system(.headline)).foregroundColor(Color(UIColor.lightText)).padding(8).truncationMode(.tail).background(in: Capsule(style: .circular)).backgroundStyle(.blue).frame(maxWidth:(UIScreen.main.bounds.width - scrollViewPadding - interitemDistance) / 2.0)
                                            if showBackgroundImage {
                                                //                                                    let _ = print(column.0.backgroundImageURL)
                                                AsyncImage(url: column.0.backgroundImageURL).cornerRadius(16.0).padding(8)
                                            } else {
                                                Spacer()
                                            }
                                        }
                                    }
                                    Spacer()
                                    ZStack {
                                        let showBackgroundImage = column.1.backgroundImageURL != nil
                                        HStack{
                                            Spacer()
                                            showBackgroundImage ?                                                                  Text(column.1.title).multilineTextAlignment(.center).font(.system(.headline)).foregroundColor(Color(UIColor.lightText)).padding(8).truncationMode(.tail).background(in: Capsule(style:.circular)).backgroundStyle(.purple).frame(maxWidth:(UIScreen.main.bounds.width - scrollViewPadding - interitemDistance) / 2.0) : Text(column.1.title).multilineTextAlignment(.center).font(.system(.headline)).foregroundColor(Color(UIColor.lightText)).padding(8).truncationMode(.tail).background(in: Capsule(style: .circular)).backgroundStyle(.blue).frame(maxWidth:(UIScreen.main.bounds.width - scrollViewPadding - interitemDistance) / 2.0)

                                            if showBackgroundImage {
                                                //                                                    let _ = print(column.1.backgroundImageURL)
                                                AsyncImage(url: column.1.backgroundImageURL).cornerRadius(16.0).padding(8)
                                            } else {
                                                Spacer()
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }.padding(scrollViewPadding)
                    }
                }.frame(height:messagesViewHeight)
            }
        }.onAppear {
            model.authorizeLocationProvider()
            model.refreshModel(resultImageSize: CGSize(width:(UIScreen.main.bounds.width - scrollViewPadding - interitemDistance) / 4.0, height:($messagesViewHeight.wrappedValue) / 2.0 - interitemDistance - scrollViewPadding))
        }
    }
    
    func createColumns(from
                       results:[ChatResult])->[(ChatResult, ChatResult)] {
        guard results.count > 1 else {
            return [(ChatResult, ChatResult)]()
        }
        
        var firstResult:ChatResult = model.results[0]
        var secondResult:ChatResult = model.results[1]
        var columns:[(ChatResult, ChatResult)] = [(ChatResult, ChatResult)]()
        
        for index in 0..<model.results.count {
            let verticalPosition = index % 2
            let result = model.results[index]
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
