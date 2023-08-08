//
//  CurrentlyReadingView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct CurrentlyReadingView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: BookCSVData.fetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "private_year == 'Reading'"))) var books: FetchedResults<BookCSVData>

    var body: some View {
        VStack {
            ForEach(books.prefix(3), id: \.self) { book in
                CurrentlyReadingTile(book: book)
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
