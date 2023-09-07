//
//  DataView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/8/23.
//

import Foundation
import SwiftUI

struct DataView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profile) private var profile
    @Environment(\.profileColor) private var profileColor

    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
    private var books: FetchedResults<BookCSVData>

    @State private var selection: BookCSVData? = nil

    @State private var searchText: String = ""
    @State private var editBook: BookCSVData? = nil
    @State private var formMode: TBRFormMode = .add

    @State private var ratingFilter: Int = 0
    
    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }
            .filter{
                searchText.isEmpty ||
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.author.lowercased().contains(searchText.lowercased()) ||
                $0.series?.lowercased().contains(searchText.lowercased()) == true
            }
        let dict = Dictionary(grouping: books, by: \.year)
            .sorted(by: { $0.key > $1.key })
            .filter{ !$1.isEmpty }
            .flatMap{
                [$0: $1.sorted(by: {
                    if case .tbr = $0.year,
                       case .tbr = $1.year {
                        return $0.dateAdded ?? .now > $1.dateAdded ?? .now
                    }
                    if $0.dateCompleted != nil,
                       $1.dateCompleted == nil {
                        return true
                    }
                    return $0.dateCompleted ?? .now > $1.dateCompleted ?? .now
                })]
            }

        NavigationStack {
            HStack {
                SearchBar(searchText: $searchText)

                if let book = selection {
                    Group {
                        Button {
                            formMode = .edit
                            editBook = selection
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.orange)
                        Button(role: .destructive) {
                            viewContext.delete(book)
                            selection = nil
                            PersistenceController.shared.save()
                        } label: {
                            Label("Trash", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .animation(.easeInOut, value: selection)

//            HStack {
//                Picker(selection: $ratingFilter, label: Text("Rating")) {
//                    ForEach(0..<6) { stars in
//                        HStack {
//                            StarRating(rating: .constant(stars))
//                                .fixedSize()
//                                .ratingStyle(SolidRatingStyle(color: profileColor))
////                            Image(systemName: "star.fill")
////                            Image(systemName: "star.fill")
////                            Image(systemName: "star")
////                            Image(systemName: "star")
//                            //                        Section {
//                            //                            HStack {
//                            //                                ForEach(0..<3) { _ in
//                            //                                    Image(systemName: "star.fill")
//                            //                                }
//                            //                                ForEach(stars..<6) { _ in
//                            //                                    Image(systemName: "star")
//                            //                                }
//                            //                            }
//                            //                            .tag(stars)
//                            //                        }
//                        }
//                        .tag(stars)
//                    }
//                }
//                .pickerStyle(.navigationLink)
//                .foregroundColor(.black)
//            }
//            TagToggles(tags: .constant([]))

            DynamicStack(alignment: .center) {
                VStack {
                    if let book = selection {
                        DataCardView(book: .constant(book))
                    }
                }
                .animation(.easeInOut, value: selection)
                
                VStack {
                    List(dict, id: \.key, selection: $selection) { year, books in
                        Section(year.description) {
                            ForEach(books, id: \.self) { book in
                                Text(book.title)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .animation(.easeInOut, value: selection)
                    .environment(\.editMode, .constant(.active))
                    
                    Button {
                        formMode = .add
                        editBook = BookCSVData()
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .padding()
                }
            }
            .sheet(item: $editBook) { (book: BookCSVData) in
                if formMode == .edit {
                    var existingTags = book.tags
                        .map{ TagToggles.ToggleState(tag: $0, state: true) }
                    let _ = existingTags.append(contentsOf: BookCSVData.defaultTags
                        .filter{ !book.tags.contains($0) }
                        .map{ TagToggles.ToggleState(tag: $0, state: false) })
                    TBRForm(
                        title: book.title,
                        author: book.author,
                        series: book.series ?? "",
                        selectedGenre: book.genre,
                        readType: book.readType ?? .owned_physical,
                        year: book.year,
                        completedDate: book.dateCompleted ?? .now,
                        rating: book.rating,
                        tags: existingTags,
                        book: book
                    )
                    .environment(\.tbrFormMode, formMode)
                } else {
                    TBRForm()
                        .environment(\.tbrFormMode, formMode)
                }
            }
            .onChange(of: formMode) { _ in () }
        }
        .padding(.horizontal)
    }
}

struct DataView_Previews : PreviewProvider {
    static private let profile = {
        let profile = ProfileEntity(context: PersistenceController.preview.container.viewContext)
        profile.uuid = UUID()
        profile.name = "Sam"

        return profile
    }()

    static var previews: some View {
        DataView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
