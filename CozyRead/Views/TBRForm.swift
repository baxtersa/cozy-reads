//
//  TBRForm.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/3/23.
//

import Foundation
import SwiftUI

enum TBRFormMode {
    case add
    case edit
}

struct TBRFormKey : EnvironmentKey {
    static var defaultValue = TBRFormMode.add
}

extension EnvironmentValues {
    var tbrFormMode: TBRFormMode {
        get { self[TBRFormKey.self] }
        set { self[TBRFormKey.self] = newValue }
    }
}

extension View where Self == TBRForm {
    func tbrFormMode(_ mode: TBRFormMode) -> some View {
        environment(\.tbrFormMode, mode)
    }
}

fileprivate struct ConfirmButtons: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profile) private var profile
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.tbrFormMode) private var mode

    @Binding var title: String
    @Binding var author: String

    @Binding var series: String

    @Binding var selectedGenre: Genre
    @Binding var readType: ReadType
    @Binding var year: Year
    @Binding var completedDate: Date
    @Binding var rating: Int

    @Binding var tags: [TagToggles.ToggleState]
    @Binding var coverId: Int?
    
    let book: BookCSVData?
    
    var body: some View {
        VStack {
            Button {
                if title.isEmpty || author.isEmpty {
                    dismiss()
                    return
                }
                
                let newBook: BookCSVData
                if let book = book {
                    newBook = book
                } else {
                    newBook = BookCSVData(context: viewContext)
                }
                newBook.dateAdded = Date.now
                newBook.title = title
                newBook.author = author
                
                if !series.isEmpty {
                    newBook.series = series
                }
                
                let setTags = tags.filter{ $0.state }
                newBook.tags = setTags.map{ $0.tag }
                if newBook.tags.isEmpty {
                    newBook.tags.append(selectedGenre.rawValue)
                }
                print(newBook.tags)
                
                newBook.setGenre(selectedGenre)
                newBook.setReadType(readType)
                newBook.setYear(year)
                if case .year = year {
                    newBook.dateCompleted = completedDate
                    newBook.rating = rating
                }

                if let coverId = coverId {
                    newBook.coverId = coverId
                }
                
                if let profile = profile.wrappedValue {
                    newBook.profile = profile
                    profile.addToBooks(newBook)
                }

                PersistenceController.shared.save()
                
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text(mode == .add ? "Add" : "Save")
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

struct TBRForm : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profileColor) private var profileColor
    @Environment(\.dismiss) private var dismiss: DismissAction

    @State var title: String = ""
    @State var author: String = ""

    @State var series: String = ""

    @State var selectedGenre: Genre = .fantasy
    @State var readType: ReadType = .owned_physical
    @State var year: Year = .tbr
    @State var completedDate: Date = .now
    @State var rating: Int = 0

    @State var tags = BookCSVData.defaultTags.map{TagToggles.ToggleState(tag: $0)}
    @State private var coverId: Int? = nil

    @State private var searchResults: [SearchResult] = []
    @State private var selectedResult: Int? = nil
    
    var book: BookCSVData? = nil
    
    var body: some View {
        VStack {
            Form {
                Section("Search") {
                    OLSearchView(results: $searchResults, selection: $selectedResult)
                        .frame(maxHeight: 300)
                }

                Section("Book Info") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Series", text: $series)
                    Picker("Genre", selection: $selectedGenre) {
                        ForEach(Genre.allCases) { (genre: Genre) in
                            Text(genre.rawValue)
                        }
                    }
                    TagToggles(tags: $tags)
                }
                
                Section("Reading Info") {
                    Picker("Read Type", selection: $readType) {
                        ForEach(ReadType.allCases) { (type: ReadType) in
                            Text(type.rawValue)
                        }
                    }
                    Picker("Progress", selection: $year) {
                        ForEach(Year.defaultSelections, id: \.self) { year in
                            Text(year.description)
                        }
                    }
                    if case let .year(num) = year {
                        if let startDate = Calendar.current.date(from: DateComponents(year: num)),
                           let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: startDate),
                           let endDate = Calendar.current.date(byAdding: .day, value: -1, to: nextYear){
                            DatePicker("Completed",
                                       selection: $completedDate,
                                       in: startDate...endDate,
                                       displayedComponents: .date)
                            HStack {
                                Text("Stars")
                                Spacer()
                                StarRating(rating: $rating)
                                    .ratingStyle(SolidRatingStyle(color: profileColor))
                                    .fixedSize()
                            }
                        }
                    }
                }

                ConfirmButtons(title: $title, author: $author, series: $series, selectedGenre: $selectedGenre, readType: $readType, year: $year, completedDate: $completedDate, rating: $rating, tags: $tags, coverId: $coverId, book: book)
            }
            .onChange(of: selectedResult) { id in
                guard let id = id else { return }
                guard let result = searchResults.first(where: { $0.id == id }) else { return }

                title = result.title
                author = result.author
                coverId = result.coverID
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
