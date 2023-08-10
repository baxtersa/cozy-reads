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
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }
    
    init(book: BookCSVData) {
        self.book = book
        self.editableBinding = Binding(get: {book.rating}, set: {book.rating = $0})
    }

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                if isEditing {
                    let titleBinding = Binding(get: { book.title }, set: { title in
                        book.title = title
                    })
                    let authorBinding = Binding(get: { book.author }, set: { author in
                        book.author = author
                    })
                    let genreBinding = Binding(get: { book.genre }, set: { genre in
                        print(genre)
                        book.setGenre(genre)
                    })
                    
                    TextField(book.title, text: titleBinding)
                        .font(.system(.title))
                        .multilineTextAlignment(.center)
                        .transition(.identity)
                    TextField(book.author, text: authorBinding)
                        .font(.system(.title3))
                        .italic()
                        .multilineTextAlignment(.center)

                    Picker("Genre", selection: genreBinding) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue)
                        }
                    }
                    .tint(.white)
                } else {
                    Text(book.title)
                        .font(.system(.title))
                        .multilineTextAlignment(.center)
                        .transition(.identity)
                    Text("by \(book.author)")
                        .font(.system(.title3))
                        .italic()
                    Text(book.genre.rawValue)
                }
                
                Spacer()
                if book.year == .tbr {
                    if isEditing {
                        Button {
                            book.setYear(.reading)
                            book.dateStarted = Date.now
                        } label: {
                            Label("To Be Read", systemImage: "circle")
                        }
                    } else {
                        Label("To Be Read", systemImage: "circle")
                    }
                } else if book.year == .reading {
                    if isEditing {
                        Button {
                            if let year = Calendar.current.dateComponents([.year], from: Date.now).year {
                                book.setYear(.year(year))
                                book.dateCompleted = Date.now
                            }
                        } label: {
                            Label("Currently Reading", systemImage: "ellipsis.circle")
                        }
                    } else {
                        Label("Currently Reading", systemImage: "ellipsis.circle")
                    }
                } else {
                    let ratingBinding = isEditing ? editableBinding : Binding.constant(book.rating)
                    
                    StarRating(rating: ratingBinding)
                        .ratingStyle(SolidRatingStyle(color: .white))

                    Spacer()
                    HStack {
                        if isEditing {
                            Button {
                                book.setYear(.tbr)
                                book.dateCompleted = nil
                            } label: {
                                Label("Finished", systemImage: "checkmark.circle")
                            }

                            let dateBinding = Binding(
                                get: {
                                    book.dateCompleted ?? Date.now
                                },
                                set: { date in
                                    book.dateCompleted = date
                                    if let started = book.dateStarted,
                                       date < started {
                                        book.dateStarted = nil
                                    }
                                })
                            DatePicker("", selection: dateBinding, displayedComponents: .date)
                                .datePickerStyle(.automatic)
                                .colorScheme(.dark)
                        } else {
                            Label("Finished", systemImage: "checkmark.circle")
                            if let dateCompleted: Date = book.dateCompleted {
                                Text("\(dateCompleted.formatted(date: .numeric, time: .omitted))")
                            }
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
    static private var finishedBook = try! BookCSVData(from: [
        "Title": "The Long Way to a Small, Angry Planet",
        "Author": "Becky Chambers",
        "Genre": "Sci-fi",
        "DateCompleted": "7/1/2023",
        "Year": "2023",
        "Rating": "4"
    ], context: PersistenceController.preview.container.viewContext)
    static private var tbrBook = try! BookCSVData(from: [
        "Title": "To Be Taught, If Fortunate",
        "Author": "Becky Chambers",
        "Genre": "Sci-fi",
        "DateAdded": "7/1/2023",
        "Year": "TBR"
    ], context: PersistenceController.preview.container.viewContext)
    
    @Environment(\.editMode) static private var editMode

    static var previews: some View {
        VStack {
            EditButton()
            DataCardView(book: finishedBook)
            DataCardView(book: tbrBook)
        }
    }
}
