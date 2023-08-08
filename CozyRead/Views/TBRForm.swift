//
//  TBRForm.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/3/23.
//

import Foundation
import SwiftUI

struct TBRForm : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Binding var title: String
    @Binding var author: String

    var body: some View {
        VStack {
            Form {
                Section("Book Info") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                }
                
                VStack {
                    Button {
                        if title.isEmpty || author.isEmpty {
                            dismiss()
                            return
                        }
                        
                        let newBook = TBREntry(context: viewContext)
                        newBook.dateAdded = Date.now
                        newBook.title = title
                        newBook.author = author
                        newBook.isbn = "1234"
                        
                        PersistenceController.shared.save()
                        
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Add")
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderless)
                    Divider()
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Cancel")
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}

struct TBRForm_Previews : PreviewProvider {
    @State static var showSheet: Bool = true
    @State static var title: String = ""
    @State static var author: String = ""

    static var previews: some View {
        VStack {
        }
        .sheet(isPresented: $showSheet) {
            TBRForm(title: $title, author: $author)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
