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
    @State var title: String = ""
    @State var author: String = ""

    @State var seriesToggle: Bool = false
    @State var series: String = ""

    @State var selectedGenre: Genre = .fantasy
    @State var readType: ReadType = .owned_physical
    
    @State var tags = BookCSVData.defaultTags.map{TagToggles.ToggleState(tag: $0)}
    
    var body: some View {
        VStack {
            Form {
                Section("Book Info") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    Picker("Genre", selection: $selectedGenre) {
                        ForEach(Genre.allCases) { (genre: Genre) in
                            Text(genre.rawValue)
                        }
                    }
                    Picker("Read Type", selection: $readType) {
                        ForEach(ReadType.allCases) { (type: ReadType) in
                            Text(type.rawValue)
                        }
                    }
                    TagToggles(tags: $tags)
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
                        
                        let setTags = tags.filter{ $0.state }
                        newBook.tags = setTags.map{ $0.tag }
                        
                        newBook.setGenre(selectedGenre)
                        newBook.setReadType(readType)

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

    static var previews: some View {
        VStack {
        }
        .sheet(isPresented: $showSheet) {
            TBRForm()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
