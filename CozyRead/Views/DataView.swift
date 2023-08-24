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

struct DataCardViewV2: View {
    @Environment(\.profileColor) private var profileColor

    let book: BookCSVData

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                // TODO: figure out why this is needed to align text to leading edge
                VStack {}
                    .frame(maxWidth: .infinity)

                Text(book.title)
                    .font(.system(.largeTitle))
                Spacer()
                if let series = book.series {
                    Text(series)
                        .font(.system(.title2))
                }
                Text("by \(book.author)")
                    .font(.system(.body))
                    .italic()

                Spacer()

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
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            let cover = book.coverId
            if cover != 0,
               let url = OLSearchView.coverUrlBase?.appendingPathComponent("\(cover)-M.jpg") {
                VStack {
                    AsyncImage(
                        url: url,
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        },
                        placeholder: {
                            ProgressView().progressViewStyle(.circular)
                        }
                    )
                    .mask {
                        RoundedRectangle(cornerRadius: 5)
                    }
                    .padding(3)
                    .background(RoundedRectangle(cornerRadius: 5)
                        .fill(.white))
                }
                .frame(maxWidth: 100, maxHeight: .infinity)
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(RoundedRectangle(cornerRadius: 20)
            .fill(profileColor))
        .padding(.horizontal)
    }
}

struct DataViewV2 : View {
    @Environment(\.profile) private var profile
    
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
    private var books: FetchedResults<BookCSVData>

    @State private var searchText: String = ""
    @State private var showSheet: Bool = false
    @State private var selectedBook: BookCSVData?
    
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
        VStack {
            SearchBar(searchText: $searchText)
                .padding(.horizontal)
            
            let selectedBook = selectedBook ?? books.first
            if let selectedBook = selectedBook {
                DataCardViewV2(book: selectedBook)
            }
            
            List(selection: $selectedBook) {
                ForEach(dict, id: \.key) { year, books in
                    Section(year.description) {
                        ForEach(books.sorted(by: {
                            if $0.dateCompleted != nil,
                               $1.dateCompleted == nil {
                                return true
                            }
                            return $0.dateCompleted ?? .now > $1.dateCompleted ?? .now
                            
                        }), id: \.self) { book in
                            Text(book.title)
                        }
                    }
                }
            }

            Button {
                showSheet.toggle()
            } label: {
                Label("Add", systemImage: "plus")
            }
            .padding(.top)
        }
        .sheet(isPresented: $showSheet) {
            TBRForm()
        }
    }
}

struct DataView_Previews : PreviewProvider {
    static var previews: some View {
//        DataView()
        DataViewV2()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
