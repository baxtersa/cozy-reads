//
//  ShelvesView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/7/23.
//

import Foundation
import SwiftUI

fileprivate enum TileType : String {
    case author
    case series
    case genre
    case year
    
    var image: String? {
        switch self {
        case .author: return "person"
        case .series: return "books.vertical"
        case .genre: return "theatermasks"
        case .year: return "calendar"
        }
    }
}

fileprivate struct ShelvesTile : View {
    fileprivate let type: TileType
    private let scaleOnTap = 1.2
    @State private var scale = 1.0

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("\(type.rawValue.capitalized)")
                .font(.system(.title3))
                .foregroundColor(.white)
                .bold()
                .padding([.leading, .top], 5)
                .italic()
            HStack {
                Spacer()
                if let image = type.image {
                    Image(systemName: image)
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(10))
                        .foregroundColor(.white)
                        .opacity(0.2)
                }
            }
        }
        .clipped()
        .frame(width: 90, height: 60)
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

struct ShelvesView : View {
//    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    @State private var showSheet: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Shelves")
                .font(.system(.title))
                .padding(.leading, 10)

            let dict = Dictionary(grouping: books, by: {$0.year})
            
//            Old stuff with tileview
//            TBRView()
//                .frame(minHeight: 600)
//            ScrollView(.horizontal) {
//                HStack(spacing: 10) {
//                    ShelvesTile(type: .author)
//                    ShelvesTile(type: .series)
//                    ShelvesTile(type: .genre)
//                    ShelvesTile(type: .year)
//                    ShelvesTile(type: .series)
//                }
//            }
//            .padding(.horizontal, 10)
        }
        .background(Color("BackgroundColor"))
    }
}

struct ShelvesView_Previews : PreviewProvider {
    static var previews: some View {
        ShelvesView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
