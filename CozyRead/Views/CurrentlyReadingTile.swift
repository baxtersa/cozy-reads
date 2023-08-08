//
//  BooksReadView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct ReadingModel {
    let title: String
    let author: String
    var bookCoverUrl: URL? = nil
}

struct CurrentlyReadingTile : View {
    let data: ReadingModel
    
    var body: some View {
        HStack {
            if let url = data.bookCoverUrl {
                AsyncImage(url: url) { image in
                    image.image?.resizable()
                }
                .mask(Circle())
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 150)
                .padding(.leading)
            } else {
                EmptyView()
            }
            VStack(alignment: .leading) {
                Text(data.title)
                    .font(.system(.title2, weight: .bold))
                Spacer()
                HStack {
                    Spacer()
                    Text("by \(data.author)")
                        .font(.system(.title3))
                        .italic()
                }
            }
            .padding(.horizontal, 5)
            .frame(maxHeight: 100)
            .padding(.vertical)
            Spacer()
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.white))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .swipeActions() {
            Button(role: .destructive) {} label: {
                Label("Complete", systemImage: "plus")
            }
                .tint(.green)
        }
    }
    
    private func finishRead() {
        
    }
}

struct CurrentlyReadingTile_Previews: PreviewProvider {
    static var data = ReadingModel(title: "The Long Way to a Small, Angry Planet", author: "Becky Chambers", bookCoverUrl: URL(string: "https://pictures.abebooks.com/isbn/9780062699220-us-300.jpg"))
    static var previews: some View {
        CurrentlyReadingTile(data: data)
    }
}
