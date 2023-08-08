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
//    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateAdded, order: .reverse)]) var tbr: FetchedResults<TBREntry>

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
                ForEach(tbr.compactMap{$0.title}, id: \.self) { title in
                    Text(title)
                }
                .onDelete { indices in
                    removeFromTBR(indices)
                }
                if tbr.isEmpty {
                    Spacer()
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.sidebar)
        }
    }

    private func removeFromTBR(_ indices: IndexSet) {
        for index in indices {
            let entry = tbr[index]
            viewContext.delete(entry)
            PersistenceController.shared.save()
        }
    }
}

struct TBRListView_Previews : PreviewProvider {
    static var previews: some View {
        TBRListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
