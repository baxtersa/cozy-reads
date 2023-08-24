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
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.editMode) var editMode: Binding<EditMode>?
    @Environment(\.profile) private var profile

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    @State private var searchText: String = ""
    @State private var selectedCard: Int = 0
    @State private var showSheet = false

    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }
        let dict: [Year:[BookCSVData]] = Dictionary(grouping: books, by: {$0.year})
        let booksByYear = dict.sorted { $0.key > $1.key }.flatMap { (year: Year, books: [BookCSVData]) in
            [year:books.filter{ (book: BookCSVData) in
                book.title.lowercased().hasPrefix(searchText.lowercased()) ||
                book.author.lowercased().hasPrefix(searchText.lowercased())
            }]
        }

        VStack {
            HStack {
                SearchBar(searchText: $searchText)
                EditButton()
                    .frame(width: 60)
                    .onSubmit {
                        PersistenceController.shared.save()
                    }
            }
            .padding(.horizontal)

            ZStack {
                TabView(selection: $selectedCard) {
                    var index = 0
                    ForEach(booksByYear.flatMap{$0.value}, id: \.self) { (book: BookCSVData) in
                        DataCardView(book: book)
                            .tag(index)
                        let _ = index += 1
                    }
                }
                .onChange(of: selectedCard, perform: { value in
                    // TODO: Figure out why we need onChange in order for card index to increment properly
                })
                .tabViewStyle(.page(indexDisplayMode: .always))
                let numItems = booksByYear.compactMap{$0.value}.compactMap{$0.count}.reduce(0, +)
                if numItems > 1 {
                    HStack {
                        Button {
                            selectedCard = max(0, selectedCard - 1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .bold()
                        }
                        .tint(.white)
                        .padding(.leading)
                        .buttonStyle(.bordered)

                        Spacer()

                        Button {
                            selectedCard = min(numItems - 1, selectedCard + 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .bold()
                        }
                        .tint(.white)
                        .padding(.trailing)
                        .buttonStyle(.bordered)
                    }
                }
            }

            List {
                let booksByYear = dict.sorted { $0.key > $1.key }.flatMap { (year: Year, books: [BookCSVData]) in
                    [year:books.filter{ (book: BookCSVData) in
                        book.title.lowercased().hasPrefix(searchText.lowercased()) ||
                        book.author.lowercased().hasPrefix(searchText.lowercased())
                    }]
                }

                ForEach(booksByYear, id: \.key) { year, books in
                    if books.isEmpty {
                        EmptyView()
                    } else {
                        Section(year.description) {
                            ForEach(books, id: \.self) { book in
                                Text(book.title)
                            }
                            .onDelete { offsets in
                                for offset in offsets {
                                    let book = books[offset]
                                    viewContext.delete(book)
                                }
                                PersistenceController.shared.save()
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            Button {
                showSheet.toggle()
            } label: {
                Label("Add", systemImage: "plus")
            }
            .padding()
        }
        .sheet(isPresented: $showSheet) {
            TBRForm()
        }
    }
}

struct DataView_Previews : PreviewProvider {
    static var previews: some View {
        DataView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
