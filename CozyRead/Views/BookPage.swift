//
//  BookPage.swift
//  CozyRead
//
//  Created by Samuel Baxter on 9/12/23.
//

import Foundation
import SwiftUI

struct BookPage : View {
    @Environment(\.managedObjectContext) private var viewContext

    let book: BookCSVData

    @Binding var formMode: TBRFormMode
    @Binding var editBook: BookCSVData?

    var body: some View {
        DataCardView(book: .constant(book))
            .toolbar {
                HStack {
                    Button {
                        formMode = .edit
                        editBook = book
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .frame(height: 20)
                    }
                    .tint(.orange)
                    
                    Button(role: .destructive) {
                        viewContext.delete(book)
                        PersistenceController.shared.save()
                    } label: {
                        Label("Trash", systemImage: "trash")
                            .frame(height: 20)
                    }
                    .tint(.red)
                }
                .buttonStyle(.bordered)
            }
    }
}
