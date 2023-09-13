//
//  DataCardView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/9/23.
//

import Foundation
import SwiftUI

struct TagInfo : View {
    var text: String
    
    var body: some View {
        Text(text)
            .padding(5)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1, opacity: 0.2)))
    }
}

struct DataCardView: View {
    @Environment(\.profileColor) private var profileColor

    @Binding var book: BookCSVData

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.system(.largeTitle))
                
                VStack(alignment: .leading) {
                    Spacer()
                    if let series = book.series {
                        Text(series)
                            .font(.system(.title2))
                    }
                    
                    Text("by \(book.author)")
                        .font(.system(.body))
                        .italic()
                    
                    Spacer()
                    
                    FlexBox(data: book.tags, spacing: 10) { tag in
                        TagInfo(text: tag)
                    }
                    
                    switch book.year {
                    case .year:
                        StarRating(rating: .constant(book.rating))
                            .ratingStyle(SolidRatingStyle(color: .white))
                            .fixedSize()
                        HStack {
                            Label("Finished", systemImage: "checkmark.circle")
                            if let dateCompleted = book.dateCompleted {
                                Spacer()
                                Text(dateCompleted.formatted(date: .abbreviated, time: .omitted))
                            }
                        }
                    case .reading:
                        Label("Currently Reading", systemImage: "ellipsis.circle")
                    case .tbr:
                        Label("To Be Read", systemImage: "circle")
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // TODO: Figure out good way to get book covers working
//            let cover = book.coverId
//            if cover != 0,
//               let url = OLSearchView.coverUrlBase?.appendingPathComponent("\(cover)-M.jpg") {
//                VStack {
//                    AsyncImage(
//                        url: url,
//                        content: { image in
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                        },
//                        placeholder: {
//                            ProgressView().progressViewStyle(.circular)
//                        }
//                    )
//                    .mask {
//                        RoundedRectangle(cornerRadius: 5)
//                    }
//                    .padding(3)
//                    .background(RoundedRectangle(cornerRadius: 5)
//                        .fill(.white))
//                }
//                .frame(maxWidth: 100, maxHeight: .infinity)
//            }
        }
        .foregroundColor(.white)
        .padding()
        .background(RoundedRectangle(cornerRadius: 20)
            .fill(profileColor))
        .padding()
    }
}

struct DataCardView_Previews : PreviewProvider {
    @State static private var finishedBook = try! BookCSVData(from: [
        "Title": "The Long Way to a Small, Angry Planet",
        "Author": "Becky Chambers",
        "Series": "Wayfarers",
        "Genre": "Sci-fi",
        "DateCompleted": "7/1/2023",
        "Year": "2023",
        "Rating": "4"
    ], context: PersistenceController.preview.container.viewContext)
    @State static private var tbrBook = try! BookCSVData(from: [
        "Title": "To Be Taught, If Fortunate",
        "Author": "Becky Chambers",
        "Genre": "Sci-fi",
        "DateAdded": "7/1/2023",
        "Year": "TBR",
        "Tags": "Sci-fi,Space Opera",
    ], context: PersistenceController.preview.container.viewContext)
    
    @Environment(\.editMode) static private var editMode

    static var previews: some View {
        VStack {
            DataCardView(book: .constant(finishedBook))
            DataCardView(book: .constant(tbrBook))
        }
    }
}
