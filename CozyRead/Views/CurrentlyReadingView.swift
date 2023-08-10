//
//  CurrentlyReadingView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct StartReadingView : View {
    var body: some View {
        VStack {
            Text("Start a new book")
                .font(.system(.title3))
                .italic()
            HStack {
                Spacer()
                Button {
                    
                } label: {
                    Label("Finished", systemImage: "plus.circle")
                        .frame(width: 200, height: 40)
                        .font(.system(.title2))
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .topTrailing))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .labelStyle(.iconOnly)
                }
                Spacer()
            }
        }
        .padding(.vertical)
        .background(RoundedRectangle(cornerRadius: 10).fill(.white))
        .cornerRadius(10)
        .padding(.horizontal, 10)
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct CurrentlyReadingView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: BookCSVData.fetchRequest(sortDescriptors: [SortDescriptor(\.dateCompleted, order: .reverse)], predicate: NSPredicate(format: "private_year == 'Reading'"))) var books: FetchedResults<BookCSVData>
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(books, id: \.self) { book in
                    CurrentlyReadingTile(book: book)
                }
                StartReadingView()
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
