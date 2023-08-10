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
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchText)
                    Spacer()
                    Image(systemName: "xmark.circle")
                        .onTapGesture {
                            searchText.removeAll()
                        }
                }
                .padding(.all, 8)
                .background(RoundedRectangle(cornerRadius: 10).fill(.black).opacity(0.08))
                EditButton()
                    .frame(width: 60)
            }
            .padding(.horizontal)
            
            TabView {
                ForEach(books.sorted {$0.year > $1.year}.filter{ (book: BookCSVData) in
                    book.title.lowercased().hasPrefix(searchText.lowercased()) ||
                    book.author.lowercased().hasPrefix(searchText.lowercased())
                }, id: \.self) { (book: BookCSVData) in
                    DataCardView(book: book)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
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
