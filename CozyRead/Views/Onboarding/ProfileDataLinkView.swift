//
//  ProfileDataLinkView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/23/23.
//

import Foundation
import SwiftUI

struct ProfileDataLinkView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profileColor) private var profileColor
    @Environment(\.dismiss) private var dismiss

    let profile: ProfileEntity

    @FetchRequest(fetchRequest: BookCSVData.fetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "profile == nil")))
    private var books: FetchedResults<BookCSVData>

    @State private var selectedBooks: Set<BookCSVData> = []

    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 5)
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .offset(y: 15)
                            .mask {
                                Circle()
                            }
                    }
                    .frame(maxWidth: 100)
                    .foregroundColor(profileColor)
                    Text(profile.name)
                        .font(.title)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height / 4)

                List(selection: $selectedBooks) {
                    ForEach(books, id: \.self) { book in
                        Text(book.title)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            for book in selectedBooks {
                                viewContext.delete(book)
                            }
                            
                            PersistenceController.shared.save()
                            selectedBooks.removeAll()
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .labelStyle(.titleAndIcon)
                                .tint(.red)
                        }
                        .disabled(selectedBooks.isEmpty)
                    }
                    ToolbarItem {
                        Button {
                            if selectedBooks.count == books.count {
                                selectedBooks.removeAll()
                            } else {
                                selectedBooks = Set(books)
                            }
                        } label: {
                            if books.isEmpty || selectedBooks.count != books.count {
                                Label("Select All", systemImage: "checkmark.circle")
                                    .labelStyle(.titleAndIcon)
                            } else {
                                Label("Unselect All", systemImage: "xmark.circle")
                                    .labelStyle(.titleAndIcon)
                            }

                        }
                        .disabled(books.isEmpty)
                    }
                }
                .environment(\.editMode, .constant(.active))
                .listStyle(.plain)

                HStack {
                    Button {
                        print(selectedBooks.map{ $0.title })
                        selectedBooks.forEach { book in
                            book.profile = profile
                        }
                        
                        PersistenceController.shared.save()
                        selectedBooks.removeAll()
                    } label: {
                        Label("Link to Profile", systemImage: "link")
                    }
                    .disabled(selectedBooks.isEmpty)

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                .padding()
            }
        }
    }
}

struct ProfileDataLinkView_Previews : PreviewProvider {
    static var profile: ProfileEntity = {
        let profile = ProfileEntity(context: PersistenceController.preview.container.viewContext)
        profile.name = "Sam"
        profile.uuid = UUID()

        return profile
    }()

    static var previews: some View {
        NavigationStack {
            ProfileDataLinkView(profile: profile)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
