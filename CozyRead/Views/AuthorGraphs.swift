//
//  AuthorGraphs.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/31/23.
//

import Charts
import Foundation
import SwiftUI

struct AuthorGraphs : View {
    let books: [String:[BookCSVData]]

    var body: some View {
        VStack {
            
        }
    }
}

struct AuthorGraphs_Previews : PreviewProvider {
    private struct PreviewWrapper : View {
        @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
        private var books: FetchedResults<BookCSVData>
        
        var body: some View {
            let dict = Dictionary(grouping: books, by: {
                $0.author
            })
            NavigationStack {
                AuthorGraphs(books: dict)
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
