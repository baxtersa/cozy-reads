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

    @State var seriesToggle: Bool = false
    @State var series: String = ""

    private static let genres = [
        "Fantasy",
        "Sci-fi",
        "Horror",
        "Contemporary"
    ]
    @State var selectedGenre: String = ""

    var body: some View {
        VStack {
            Form {
                Section("Book Info") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    Picker("Genre", selection: $selectedGenre) {
                        ForEach(TBRForm.genres, id: \.self) { genre in
                            Text(genre)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Series Info") {
                    Toggle("Belongs to a series", isOn: $seriesToggle)
                    if seriesToggle {
                        TextField("Series", text: $series)
                    }
                }

                VStack {
                    Button {
                        if title.isEmpty || author.isEmpty {
                            dismiss()
                            return
                        }
                        
                        let newBook = BookCSVData(managedContext: viewContext)
                        newBook.dateAdded = Date.now
                        newBook.title = title
                        newBook.author = author
                        
                        if !series.isEmpty {
                            newBook.series = series
                        }
                        
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
