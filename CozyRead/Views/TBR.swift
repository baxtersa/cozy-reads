//
//  TBR.swift
//  CozyRead
//
//  Created by Samuel Baxter on 9/6/23.
//

import Foundation
import SwiftUI

struct SelectBookSheet : View {
    @Environment(\.profile) private var profile

    let books: [BookCSVData]

    @State private var searchText: String = ""
    @State private var addBook: Bool = false

    @Binding var showSheet: Bool

    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }
        if addBook {
            TBRForm()
        } else {
            NavigationStack {
                List {
                    Section("TBR") {
                        let tbr = books.filter{ $0.year == .tbr }.filter{ (book: BookCSVData) in
                            searchText.isEmpty ||
                            book.title.localizedCaseInsensitiveContains(searchText) ||
                            book.author.localizedCaseInsensitiveContains(searchText) ||
                            book.series?.localizedCaseInsensitiveContains(searchText) == true
                        }
                        ForEach(tbr, id: \.self) { book in
                            HStack(spacing: 10) {
                                if book.coverId != 0,
                                   let coverUrl = OLSearchView.coverUrlBase?.appending(path: "\(book.coverId)-M.jpg") {
                                    AsyncImage(
                                        url: coverUrl,
                                        content: { image in
                                            image
                                                .resizable()
                                        },
                                        placeholder: {
                                            ProgressView().progressViewStyle(.circular)
                                        }
                                    )
                                    .mask {
                                        Circle()
                                    }
                                    .frame(width: 70, height: 70)
                                }
                                VStack(alignment: .leading) {
                                    Text(book.title)
                                        .font(.system(.title3))
                                    HStack {
                                        Spacer()
                                        Text("by \(book.author)")
                                            .italic()
                                            .font(.system(.footnote))
                                    }
                                }
                                .swipeActions {
                                    Button {
                                        book.setYear(.reading)
                                        book.dateStarted = Date.now
                                        
                                        PersistenceController.shared.save()
                                        showSheet = false
                                    } label: {
                                        Text("Start Reading")
                                    }
                                    .tint(.green)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                
                Button {
                    addBook.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .searchable(text: $searchText)
            .padding()
        }
    }
}

struct StartReadingView : View {
    @State private var showSheet: Bool = false
    @State private var searchText: String = ""
    
    let books: [BookCSVData]
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    showSheet.toggle()
                } label: {
                    Label("Add", systemImage: "plus.circle")
                }
                .buttonStyle(.bordered)
            }
        }
        .sheet(isPresented: $showSheet) {
            SelectBookSheet(books: books, showSheet: $showSheet)
        }
    }
}

struct TBR : View {
    @Environment(\.profile) private var profile

    @FetchRequest(fetchRequest: BookCSVData.fetchRequest(
        sortDescriptors: [SortDescriptor(\.dateAdded, order: .reverse)],
        predicate: NSPredicate(format: "private_year == 'TBR'")
    ))
    private var books: FetchedResults<BookCSVData>
    
    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }

        VStack(alignment: .leading) {
            Text("To Read")
                .font(.system(.title2))
                .bold()

            VStack {
                HStack {
                    Label("\(books.count) books", systemImage: "book")
                        .font(.system(.title3))
                    Spacer()
                    StartReadingView(books: Array(books))
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
            }
            .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        }
        .padding(.horizontal)
    }
}

struct TBR_Previews : PreviewProvider {
    static var previews: some View {
        TBR()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
