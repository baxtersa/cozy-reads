//
//  DataCardView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/9/23.
//

import Foundation
import SwiftUI

struct TagInfo : View {
    @Environment(\.editMode) private var editMode
    private var isEditing: Bool { editMode?.wrappedValue.isEditing == true }

    let book: BookCSVData
    var text: String
    @State private var editText: String = ""
    
    var body: some View {
        ZStack {
            if isEditing {
                HStack {
                    Text(text)
                    //                    TextField("Edit", text: $editText)
                    //                        .onSubmit {
                    //                            if let originalTagIndex = book.tags.firstIndex(of: text) {
                    //                                book.tags[originalTagIndex] = editText
                    //                                PersistenceController.shared.save()
                    //                            }
                    //                        }
                    Image(systemName: "xmark.circle")
                        .onTapGesture {
                            book.tags.removeAll { $0 == text }
                            PersistenceController.shared.save()
                        }
                }
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1, opacity: 0.2)))
            } else {
                Text(text)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1, opacity: 0.2)))
            }
        }
    }
}

struct AddTag : View {
//    let book: BookCSVData

    @State private var typing: Bool = false
    @FocusState private var focusTagEntry: Bool
    @Binding var newTag: String
    
    var body: some View {
        if typing {
            TextField("Enter Tag", text: $newTag)
                .onSubmit {
                    typing.toggle()
                    newTag.removeAll()
                    focusTagEntry = false
                }
                .focused($focusTagEntry)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1, opacity: 0.2)))
        } else {
            Button {
                typing.toggle()
                focusTagEntry = true
            } label: {
                Text("Add Tag")
            }
            .buttonStyle(.bordered)
        }
    }
}

struct DataCardView : View {
    @Environment(\.editMode) private var editMode: Binding<EditMode>?
    @State private var newTag: String = ""

    let book: BookCSVData
    private let editableBinding: Binding<Int>
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }
    
    init(book: BookCSVData) {
        self.book = book
        self.editableBinding = Binding(
            get: {book.rating},
            set: { value in
                book.rating = value
                PersistenceController.shared.save()
            })
    }

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                if isEditing {
                    let titleBinding = Binding(get: { book.title }, set: { title in
                        book.title = title
                        PersistenceController.shared.save()
                    })
                    let authorBinding = Binding(get: { book.author }, set: { author in
                        book.author = author
                        PersistenceController.shared.save()
                    })
                    
                    TextField(book.title, text: titleBinding)
                        .font(.system(.title))
                        .multilineTextAlignment(.center)
                        .transition(.identity)
                    TextField(book.author, text: authorBinding)
                        .font(.system(.title3))
                        .italic()
                        .multilineTextAlignment(.center)

                    // TODO: Figure out UX for if I want to treat genre separate from tags
//                    let genreBinding = Binding(get: { book.genre }, set: { genre in
//                        book.setGenre(genre)
//                    })
//                    Picker("Genre", selection: genreBinding) {
//                        ForEach(Genre.allCases) { genre in
//                            Text(genre.rawValue)
//                        }
//                    }
//                    .tint(.white)
                } else {
                    Text(book.title)
                        .font(.system(.title))
                        .multilineTextAlignment(.center)
                        .transition(.identity)
                    Text("by \(book.author)")
                        .font(.system(.title3))
                        .italic()
                    // TODO: See above about how to treat Genre
//                    Text(book.genre.rawValue)
                }

                Spacer()

                FlexBox(data: book.tags, spacing: 10) { tag in
                    TagInfo(book: book, text: tag)
                }
                if isEditing {
                    AddTag(newTag: $newTag)
                        .onSubmit {
                            book.tags.append(newTag)

                            PersistenceController.shared.save()
                        }
                }

                if book.year == .tbr {
                    if isEditing {
                        Button {
                            book.setYear(.reading)
                            book.dateStarted = Date.now

                            PersistenceController.shared.save()
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

                                PersistenceController.shared.save()
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
                        .fixedSize()
                        .ratingStyle(SolidRatingStyle(color: .white))

                    Spacer()

                    HStack {
                        if isEditing {
                            Button {
                                book.setYear(.tbr)
                                book.dateCompleted = nil
                                
                                PersistenceController.shared.save()
                            } label: {
                                Label("Finished", systemImage: "checkmark.circle")
                            }
                            .buttonStyle(.bordered)

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
                                    
                                    let yearCompleted = Calendar.current.component(.year, from: date)
                                    let prev = book.year
                                    if case let .year(num) = prev,
                                       yearCompleted != num {
                                        book.setYear(.year(yearCompleted))
                                    }
                                    
                                    PersistenceController.shared.save()
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
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.accentColor))
        .padding()
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct DataCardView_Previews : PreviewProvider {
    @State static private var finishedBook = try! BookCSVData(from: [
        "Title": "The Long Way to a Small, Angry Planet",
        "Author": "Becky Chambers",
        "Genre": "Sci-fi",
        "DateCompleted": "7/1/2023",
        "Year": "2023",
        "Rating": "4"
    ], context: PersistenceController.preview.container.viewContext)
    @State static private var tbrBook = try! BookCSVData(from: [
        "Title": "To Be Taught, If Fortunate",
        "Author": "Becky Chambers",
        "Genre": "Sci-fi",
        "DateAdded": "7/1/2023",
        "Year": "TBR",
        "Tags": "Sci-fi,Space Opera",
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
