//
//  CurrentlyReadingView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct SelectBookSheet : View {
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) private var books: FetchedResults<BookCSVData>

    @State private var searchText: String = ""
    @State private var addBook: Bool = false

    @Binding var showSheet: Bool

    var body: some View {
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
                
                Button {
                    addBook.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .padding()
            .background(Color("BackgroundColor"))
        }
    }
}

struct StartReadingView : View {
    @State private var showSheet: Bool = false
    @State private var searchText: String = ""

    var body: some View {
        VStack {
            Text("Start a new book")
                .font(.system(.title3))
                .italic()
            HStack {
                Spacer()
                Button {
                    showSheet.toggle()
                } label: {
                    Label("Finished", systemImage: "plus.circle")
                        .frame(width: 200, height: 40)
                        .font(.system(.title2))
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .topTrailing))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .labelStyle(.iconOnly)
                }
                Spacer()
            }
        }
        .padding(.vertical)
        .background(RoundedRectangle(cornerRadius: 10).fill(.white))
        .cornerRadius(10)
        .padding(.horizontal, 10)
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .sheet(isPresented: $showSheet) {
            SelectBookSheet(showSheet: $showSheet)
        }
    }
}

struct CurrentlyReadingView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: BookCSVData.fetchRequest(sortDescriptors: [SortDescriptor(\.dateCompleted, order: .reverse)], predicate: NSPredicate(format: "private_year == 'Reading'"))) var books: FetchedResults<BookCSVData>
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(books, id: \.self) { book in
                    CurrentlyReadingTile(book: book)
                }
                StartReadingView()
            }
        }
    }
}

struct CurrentlyReadingView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentlyReadingView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
