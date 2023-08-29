//
//  DataView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/8/23.
//

import Foundation
import SwiftUI

struct SearchBar : View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $searchText)
            Spacer()
            if !searchText.isEmpty {
                Image(systemName: "xmark.circle")
                    .onTapGesture {
                        searchText.removeAll()
                    }
            }
        }
        .padding(.all, 8)
        .background(RoundedRectangle(cornerRadius: 10).opacity(0.08))
    }
}

struct DataView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profile) private var profile
    
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
    private var books: FetchedResults<BookCSVData>

    @State private var selection: BookCSVData? = nil

    @State private var searchText: String = ""
    @State private var editBook: BookCSVData? = nil
    @State private var formMode: TBRFormMode = .add
    
    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }
            .filter{
                $0.title.lowercased().hasPrefix(searchText.lowercased()) ||
                $0.author.lowercased().hasPrefix(searchText.lowercased()) ||
                $0.series?.lowercased().hasPrefix(searchText.lowercased()) == true
            }
        let dict = Dictionary(grouping: books, by: \.year)
            .sorted(by: { $0.key > $1.key })
            .filter{ !$1.isEmpty }
            .flatMap{
                [$0: $1.sorted(by: {
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
//                    .labelStyle(.iconOnly)
                }
            }
            .padding(.horizontal)
            .animation(.easeInOut, value: selection)

            DynamicStack(alignment: .center) {
                VStack {
                    if let book = selection {
                        DataCardView(book: .constant(book))
                    }
                }
                .animation(.easeInOut, value: selection)
                
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
            .toolbar {
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
