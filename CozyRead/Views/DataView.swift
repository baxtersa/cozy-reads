//
//  DataView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/8/23.
//

import Foundation
import SwiftUI

struct DataView : View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.editMode) var editMode: Binding<EditMode>?
    
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    @State private var searchText: String = ""
    @State private var selectedCard: Int = 0
    
    var body: some View {
        let dict: [Year:[BookCSVData]] = Dictionary(grouping: books, by: {$0.year})
        let booksByYear = dict.sorted { $0.key > $1.key }.map { (year: Year, books: [BookCSVData]) in
            books.filter{ (book: BookCSVData) in
                book.title.lowercased().hasPrefix(searchText.lowercased()) ||
                book.author.lowercased().hasPrefix(searchText.lowercased())
            }
        }

        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchText)
                    Spacer()
                    if !searchText.isEmpty {
                        Image(systemName: "xmark.circle")
                            .onTapGesture {
                                searchText.removeAll()
//                                selectedCard = 0
                            }
                    }
                }
                .padding(.all, 8)
                .background(RoundedRectangle(cornerRadius: 10).fill(.black).opacity(0.08))
                EditButton()
                    .frame(width: 60)
            }
            .padding(.horizontal)
            
            ZStack {
                TabView(selection: $selectedCard) {
                    var index = 0
                    //                ForEach(booksByYear, id: \.self) { books in
                    //                    ForEach(books, id: \.self) { book in
                    //                        DataCardView(book: book)
                    //                            .tag(index)
                    //                        let _ = index += 1
                    //                    }
                    //                }
                    ForEach(books.sorted {$0.year > $1.year}.filter{ (book: BookCSVData) in
                        book.title.lowercased().hasPrefix(searchText.lowercased()) ||
                        book.author.lowercased().hasPrefix(searchText.lowercased())
                    }, id: \.self) { (book: BookCSVData) in
                        DataCardView(book: book)
                            .tag(index)
                        let _ = index += 1
                    }
                }
                .onChange(of: selectedCard, perform: { value in
                    print(value)
                })
                .tabViewStyle(.page(indexDisplayMode: .always))
                let numItems = booksByYear.compactMap{$0.count}.reduce(0, +)
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
                let dict: [Year:[BookCSVData]] = Dictionary(grouping: books, by: {$0.year})
                ForEach(dict.sorted { $0.key > $1.key }, id: \.key) { (year: Year, books: [BookCSVData]) in
                    Section(year.description) {
                        ForEach(books.filter{ (book: BookCSVData) in
                            book.title.lowercased().hasPrefix(searchText.lowercased()) ||
                            book.author.lowercased().hasPrefix(searchText.lowercased())
                        }, id: \.self) { (book: BookCSVData) in
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
            Button {
                let book = BookCSVData(context: viewContext)
                book.title = "Title"
                book.author = "Author"
                
                PersistenceController.shared.save()
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
        .background(Color("BackgroundColor"))
    }
}

struct DataView_Previews : PreviewProvider {
    static var previews: some View {
        DataView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
