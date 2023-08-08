//
//  HistoryView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/7/23.
//

import Foundation
import SwiftUI

private enum TileType {
    case author
    case series
    case genre
    case year

    var description : String {
        switch self {
        case .author: return "Author"
        case .series: return "Series"
        case .genre: return "Genre"
        case .year: return "Year"
        }
    }
    
    var image: String? {
        switch self {
        case .author: return "person"
        case .series: return "books.vertical"
        case .genre: return "theatermasks"
        case .year: return "calendar"
        }
    }
}

fileprivate struct HistoryTile : View {
    fileprivate let type: TileType
    private let scaleOnTap = 1.2
    @State private var scale = 1.0

    var body: some View {
        VStack(alignment: .leading) {
            Text("By \(type.description)")
                .font(.system(.title3))
                .foregroundColor(.white)
                .bold()
                .padding([.leading, .top])
                .italic()
            Spacer()
            HStack {
                Spacer()
                if let image = type.image {
                    Image(systemName: image)
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(10))
                        .foregroundColor(.white)
                        .opacity(0.3)
                }
            }
        }
        .clipped()
        .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .topTrailing)))
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 0.2), value: scale)
        .onTapGesture {
            scale = scaleOnTap
            withAnimation {
                scale = 1.0
            }
        }
    }
}

struct HistoryView : View {
    @State private var showSheet: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("History")
                .font(.system(.title))
                .padding(.leading, 10)
            Spacer()
                .frame(minHeight: 0)
            Grid(horizontalSpacing: 10) {
                GridRow {
                    HistoryTile(type: .author)
                    HistoryTile(type: .series)
                }
                GridRow {
                    HistoryTile(type: .genre)
                    HistoryTile(type: .year)
                }
            }
            .padding(.horizontal, 10)
//            HStack(alignment: .bottom) {
//                Spacer()
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .topTrailing))
//                    .frame(width: 50, height: 15)
//                    .onTapGesture {
//                        showSheet.toggle()
//                    }
//                Spacer()
//            }
        }
        .background(Color("BackgroundColor"))
//        .sheet(isPresented: $showSheet) {
//            .background(Color("BackgroundColor"))
//            .padding()
//            .presentationDetents([.fraction(0.4)])
//        }
    }
}

struct HistoryView_Previews : PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
