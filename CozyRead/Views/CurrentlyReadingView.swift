//
//  CurrentlyReadingView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct SelectBookSheet : View {
    @Environment(\.profile) private var profile

    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) private var books: FetchedResults<BookCSVData>

    @State private var searchText: String = ""
    @State private var addBook: Bool = false

    @Binding var showSheet: Bool

    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }
        if addBook {
            TBRForm(year: .reading)
        } else {
            VStack {
                SearchBar(searchText: $searchText)
                
                List {
                    Section("TBR") {
                        let tbr = books.filter{ $0.year == .tbr }.filter{ (book: BookCSVData) in
                            book.title.lowercased().hasPrefix(searchText.lowercased()) ||
                            book.author.lowercased().hasPrefix(searchText.lowercased())
                        }
                        ForEach(tbr, id: \.self) { book in
                            HStack {
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
            .padding()
        }
    }
}

struct StartReadingView : View {
    @State private var showSheet: Bool = false
    @State private var searchText: String = ""

    var body: some View {
        VStack {
            HStack {
                Button {
                    showSheet.toggle()
                } label: {
                    Label("New Book", systemImage: "plus.circle")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $showSheet) {
            SelectBookSheet(showSheet: $showSheet)
        }
    }
}

struct CurrentlyReadingView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profile) private var profile

    @FetchRequest(fetchRequest: BookCSVData.fetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "private_year == 'Reading'")
    )) var books: FetchedResults<BookCSVData>
    
    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }

        VStack(alignment: .leading) {
            HStack {
                Text("Currently Reading")
                    .font(.system(.title2))
                Spacer()
                StartReadingView()
            }
        .padding(.horizontal)
            ScrollView {
                ForEach(books, id: \.self) { book in
                    CurrentlyReadingTile(book: book)
                }
            }
        }
        .onChange(of: profile.wrappedValue) { _ in
            print("Profile change propogated")
        }
        .onAppear {
            print("Currently reading appeared with profile: ", profile.wrappedValue?.name)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CurrentlyReadingView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentlyReadingView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
