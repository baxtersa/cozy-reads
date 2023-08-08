//
//  TBRListView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/7/23.
//

import Foundation
import SwiftUI

struct TBRListView : View {
    @Environment(\.managedObjectContext) var viewContext

    @State var showSheet: Bool = false
    @State var title: String = ""
    @State var author: String = ""

    @FetchRequest(fetchRequest: BookCSVData.fetchRequest(
        sortDescriptors: [SortDescriptor(\.dateAdded, order: .reverse)],
        predicate: NSPredicate(format: "private_year == 'TBR'"))
    ) var tbr: FetchedResults<BookCSVData>

    var body: some View {
        VStack {
            HStack {
                Text("To Be Read")
                    .font(.system(.title2))
                    .padding([.horizontal, .top], 10)
                Spacer()
                Button {
                    showSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(.title))
                }
                .padding(.trailing)
                .sheet(isPresented: $showSheet, onDismiss: {
                    title.removeAll()
                    author.removeAll()
                }) {
                    TBRForm(title: $title, author: $author)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            List {
                ForEach(tbr, id: \.self) { book in
                    Text(book.title)
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                removeFromTBR(book)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                startReading(book)
                            } label: {
                                Text("Start")
                            }
                        }
                }
                if tbr.isEmpty {
                    Spacer()
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.sidebar)
        }
    }

    private func startReading(_ book: BookCSVData) {
        book.setYear(.reading)
        PersistenceController.shared.save()
    }

    private func removeFromTBR(_ book: BookCSVData) {
        viewContext.delete(book)
        PersistenceController.shared.save()
    }
}

struct TBRListView_Previews : PreviewProvider {
    static var previews: some View {
        TBRListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
