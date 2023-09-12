//
//  BookList.swift
//  CozyRead
//
//  Created by Samuel Baxter on 9/12/23.
//

import Foundation
import SwiftUI

struct BookList<Category: Hashable, Content: View> : View {
    let data: [Dictionary<Category, [BookCSVData]>.Element]
    
    let sectionTitle: (Category) -> String
    let itemLabel: (BookCSVData) -> Content

    @State private var formMode: TBRFormMode = .add
    @State private var editBook: BookCSVData? = nil
    
    var body: some View {
        List(data, id: \.key) { category, books in
            Section(sectionTitle(category)) {
                ForEach(books) { book in
                    NavigationLink {
                        DataCardView(book: .constant(book))
                    } label: {
                        itemLabel(book)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}

private struct YearList : View {
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
    private var books: FetchedResults<BookCSVData>
    
    var body: some View {
        let dict = Dictionary(grouping: books, by: {
            $0.year
        })
            .sorted(by: { $0.key > $1.key })
        BookList(data: dict, sectionTitle: { $0.description }) { book in
            VStack(alignment: .leading, spacing: 10) {
                Text(book.title)
                    .font(.system(.title3))
                HStack {
                    if let series = book.series {
                        Text(series)
                            .font(.system(.caption))
                    }
                    Spacer()
                    Text("by \(book.author)")
                        .italic()
                        .font(.system(.footnote))
                }
            }
        }
    }
}

struct BookList_Previews : PreviewProvider {
    static var previews: some View {
        NavigationStack {
            YearList()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
