//
//  DataCardView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/9/23.
//

import Foundation
import SwiftUI

struct DataCardView : View {
    @Environment(\.editMode) private var editMode: Binding<EditMode>?
    
    let book: BookCSVData
    private let editableBinding: Binding<Int>
    
    init(book: BookCSVData) {
        self.book = book
        self.editableBinding = Binding(get: {book.rating}, set: {book.rating = $0})
    }
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                if editMode?.wrappedValue.isEditing == true {
                    let titleBinding = Binding(get: { book.title }, set: { title in
                        book.title = title
                    })
                    let authorBinding = Binding(get: { book.author }, set: { author in
                        book.author = author
                    })
                    
                    TextField(book.title, text: titleBinding)
                        .font(.system(.title))
                        .multilineTextAlignment(.center)
                        .transition(.identity)
                    HStack {
                        TextField(book.author, text: authorBinding)
                            .font(.system(.title3))
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text(book.title)
                        .font(.system(.title))
                        .multilineTextAlignment(.center)
                        .transition(.identity)
                    Text("by \(book.author)")
                        .font(.system(.title3))
                        .italic()
                }
                
                if book.year == .tbr || book.year == .reading {
                    Spacer()
                } else {
                    let ratingBinding =
                        editMode?.wrappedValue.isEditing == true ?
                        editableBinding :
                        Binding.constant(book.rating)
                    
                    Spacer()
                    StarRating(rating: ratingBinding)
                        .ratingStyle(SolidRatingStyle(color: .white))
                    Spacer()
                    
                    HStack {
                        Label("Finished", systemImage: "checkmark.circle")
                            .symbolVariant(book.year == .tbr ? .none : .fill)
                        if let dateCompleted: Date = book.dateCompleted {
                            let _ = dateCompleted.formatted(date: .numeric, time: .omitted)
                            Text("Complete: \(dateCompleted.formatted(date: .numeric, time: .omitted))")
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom])
            Spacer()
        }
        .padding(.vertical)
        .foregroundColor(.white)
        .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .bottomLeading, endPoint: .topTrailing)))
        .padding()
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct DataCardView_Previews : PreviewProvider {
    static private var book = try! BookCSVData(from: [
        "Title": "The Long Way to a Small, Angry Planet",
        "Author": "Becky Chambers",
        "Genre": "Sci-fi",
        "DateCompleted": "7/1/2023",
        "Year": "2023",
        "Rating": "4"
    ], context: PersistenceController.preview.container.viewContext)

    static var previews: some View {
        DataCardView(book: book)
            .environment(\.editMode, Binding.constant(EditMode.active))
    }
}
