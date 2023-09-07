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
    @Environment(\.profileColor) private var profileColor

    let book: BookCSVData
    
    @State private var expand: Bool = false
    @State private var rating: Int = 0
    
    var body: some View {
        VStack(spacing: 10) {
            VStack {
                HStack {
                    Text(book.title)
                        .font(.system(.title3))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .animation(.easeInOut, value: expand)
                        .rotationEffect(.degrees(expand ? 0 : -90))
                }
                HStack {
                    Spacer()
                    Text("by \(book.author)")
                        .italic()
                }
            }
//            .frame(maxHeight: 100)
            if expand {
                VStack {
                    StarRating(rating: $rating)
                        .ratingStyle(SolidRatingStyle(color: profileColor))
                        .frame(width: 200)
                    Button {
                        finishRead()
                        
                        expand.toggle()
                    } label: {
                        Label("Finished", systemImage: "checkmark")
                    }
                    .buttonStyle(.bordered)
                }
//                .frame(maxHeight: 80)
                .clipped()
            }
        }
        .padding()
//        .background {
//            ZStack(alignment: .top) {
//                Rectangle()
//                    .fill(Color(uiColor: .systemBackground))
//                Rectangle()
//                    .frame(maxHeight: 10)
//                    .foregroundColor(profileColor)
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//        }
        .background(Color(uiColor: .systemBackground))
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
