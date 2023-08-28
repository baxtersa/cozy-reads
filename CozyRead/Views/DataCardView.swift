//
//  DataCardView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/9/23.
//

import Foundation
import SwiftUI

struct TagInfo : View {
    @Environment(\.editMode) private var editMode
    private var isEditing: Bool { editMode?.wrappedValue.isEditing == true }

    let book: BookCSVData
    var text: String
    @State private var editText: String = ""
    
    var body: some View {
        ZStack {
            if isEditing {
                HStack {
                    Text(text)
                    //                    TextField("Edit", text: $editText)
                    //                        .onSubmit {
                    //                            if let originalTagIndex = book.tags.firstIndex(of: text) {
                    //                                book.tags[originalTagIndex] = editText
                    //                                PersistenceController.shared.save()
                    //                            }
                    //                        }
                    Image(systemName: "xmark.circle")
                        .onTapGesture {
                            book.tags.removeAll { $0 == text }
                            PersistenceController.shared.save()
                        }
                }
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1, opacity: 0.2)))
            } else {
                Text(text)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1, opacity: 0.2)))
            }
        }
    }
}

struct AddTag : View {
//    let book: BookCSVData

    @State private var typing: Bool = false
    @FocusState private var focusTagEntry: Bool
    @Binding var newTag: String
    
    var body: some View {
        if typing {
            TextField("Enter Tag", text: $newTag)
                .onSubmit {
                    typing.toggle()
                    newTag.removeAll()
                    focusTagEntry = false
                }
                .focused($focusTagEntry)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1, opacity: 0.2)))
        } else {
            Button {
                typing.toggle()
                focusTagEntry = true
            } label: {
                Text("Add Tag")
            }
            .buttonStyle(.bordered)
        }
    }
}

struct DataCardView: View {
    @Environment(\.profileColor) private var profileColor

    @Binding var book: BookCSVData

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                // TODO: figure out why this is needed to align text to leading edge
                VStack {}
                    .frame(maxWidth: .infinity)

                Text(book.title)
                    .font(.system(.largeTitle))
                
//                HStack {
                    VStack(alignment: .leading, spacing: 10) {
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
                        TagInfo(book: book, text: tag)
                    }

                        switch book.year {
                        case .year:
                            StarRating(rating: .constant(book.rating))
                                .ratingStyle(SolidRatingStyle(color: .white))
                                .fixedSize()
                            Label("Finished", systemImage: "checkmark.circle")
                        case .reading:
                            Label("Currently Reading", systemImage: "ellipsis.circle")
                        case .tbr:
                            Label("To Be Read", systemImage: "circle")
                        }
                    }
//                }
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
            EditButton()
            DataCardView(book: .constant(finishedBook))
            DataCardView(book: .constant(tbrBook))
        }
    }
}
