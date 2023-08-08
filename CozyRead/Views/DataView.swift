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
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
//    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateAdded, order: .reverse)]) var books: FetchedResults<BookCSVData>
    
    var body: some View {
        VStack {
            List {
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
            Button {
                let book = BookCSVData(context: viewContext)
                book.title = "Title"
                book.author = "Author"

                PersistenceController.shared.save()
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
    }
}

struct DataView_Previews : PreviewProvider {
    static var previews: some View {
        DataView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
