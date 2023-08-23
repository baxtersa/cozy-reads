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
    let book: BookCSVData
    
    @State private var expand: Bool = false
    @State private var rating: Int = 0
    
//    let data: ReadingModel

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(book.title)
                            .font(.system(.title3))
                            .bold()
                            .padding(.leading)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .animation(.easeInOut, value: expand)
                            .rotationEffect(.degrees(expand ? 0 : -90))
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text("by \(book.author)")
                            .font(.system(.title3))
                            .italic()
                    }
                }
                .padding(.horizontal, 5)
                .frame(maxHeight: 100)
                .padding([.vertical, .trailing])
            }
            if expand {
                VStack(spacing: 10) {
                    StarRating(rating: $rating)
                        .ratingStyle(SolidRatingStyle(color: .accentColor))
                        .frame(width: 200)
                    Button {
                        finishRead()
                        
                        expand.toggle()
                    } label: {
                        Label("Finished", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom)
                }
                .frame(maxHeight: 120)
                .clipped()
            }
        }
        .background(Color(uiColor: .systemBackground))
//        .background {
//            ZStack(alignment: .top) {
//                Rectangle()
//                    .fill(Color(uiColor: .systemBackground))
//                Rectangle()
//                    .frame(maxHeight: 10)
//                    .foregroundColor(.accentColor)
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//        }
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .animation(.linear(duration: 0.2), value: expand)
        .onTapGesture {
            withAnimation {
                expand.toggle()
            }
        }
    }

    private func finishRead() {
        let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023
        book.setYear(.year(currentYear))

        book.rating = rating
        book.dateCompleted = Date.now

//        XPLevels.shared.finishedBook()

        PersistenceController.shared.save()
    }
}

struct CurrentlyReadingTile_Previews: PreviewProvider {
    static private var book = try! BookCSVData(from: ["Title": "The Long Way to a Small, Angry Planet", "Author": "Becky Chambers", "Genre": "Sci-fi", "CoverID": "8902659"], context: PersistenceController.preview.container.viewContext)

    static var previews: some View {
        CurrentlyReadingTile(book: book)
    }
}
