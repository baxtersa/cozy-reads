//
//  ShelvesView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/7/23.
//

import Foundation
import Charts
import SwiftUI
//import SwiftUICharts

fileprivate enum Category : String, CaseIterable {
    case author
//    case series
    case genre
    case year
}

struct ShelvesView : View {
    @Environment(\.profile) private var profile

    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>

    private let currentYear = Calendar.current.dateComponents([.year], from: .now).year ?? 2023

    @State private var year: Year = .year(Calendar.current.dateComponents([.year], from: .now).year ?? 2023)
    @State private var categoryFilter: Category = .year
    @State private var tagFilter: [TagToggles.ToggleState] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let books = books
                .filter{ $0.profile == profile.wrappedValue }
                .filter{ $0.tags.contains{ bookTag in
                    tagFilter.contains { toggle in
                        toggle.tag == bookTag && toggle.state
                    }
                } }

            HStack {
                Text("Shelves")
                    .font(.system(.title))

                if categoryFilter != .year {
                    let years: [Year] = Array(Set(books.map{ $0.year })).sorted()
                    Picker("Year", selection: $year) {
                        ForEach(Array(years)) { year in
                            Text(year.description)
                        }
                    }
                    .pickerStyle(.menu)
                }


                Spacer()
                
                Reports(year: year) {
                    Image(systemName: "play.fill")
                }
            }

            Picker("Filter by", selection: $categoryFilter) {
                ForEach(Category.allCases, id: \.self) { filter in
                    Text(filter.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            
            TagToggles(tags: $tagFilter)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                }

            NavigationStack {
                ScrollView {
                    switch categoryFilter {
                    case .author:
                        let dict = Dictionary(grouping: books, by: {
                            $0.author
                        })
                        AuthorGraphs(books: dict, year: $year)
                    case .genre:
                        let dict = Dictionary(grouping: books, by: {
                            $0.genre
                        })
                        GenreGraphs(books: dict, year: $year)
                    case .year:
                        let dict = Dictionary(grouping: books, by: {
                            $0.year
                        })
                        YearlyGraphs(books: dict)
                    }
                }
            }
            .animation(.linear, value: categoryFilter)
            .animation(.linear, value: tagFilter)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
        .onAppear {
            tagFilter = Array(Set(books
                .flatMap{ $0.tags }))
            .map{ tag in
                TagToggles.ToggleState(tag: tag, state: !books.filter{
                    $0.tags.contains(tag)
                }.isEmpty)
            }
        }
        .onChange(of: categoryFilter) { _ in
            tagFilter = Array(Set(books
                .filter{ $0.year == year }
                .flatMap{ $0.tags }))
            .map{ tag in
                TagToggles.ToggleState(tag: tag, state: !books.filter{
                    $0.tags.contains(tag)
                }.isEmpty)
            }
        }
    }
}

struct ShelvesView_Previews : PreviewProvider {
    static var previews: some View {
        ShelvesView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
