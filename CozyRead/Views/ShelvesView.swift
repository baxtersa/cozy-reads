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
    case series
    case genre
    case year
}

enum YearFilter: Hashable {
    case all_time
    case year(year: Year)
}

struct ShelvesView : View {
    static private let defaultCategory = "default_category"
    
    @Environment(\.profile) private var profile

    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>

    private let currentYear = Calendar.current.dateComponents([.year], from: .now).year ?? 2023

    @State private var year: YearFilter = .year(year:  .year(Calendar.current.dateComponents([.year], from: .now).year ?? 2023))
    @State private var tagFilter: [TagToggles.ToggleState] = []

    @AppStorage(ShelvesView.defaultCategory) private var categoryFilter: Category = .year

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
                        Text("All-Time")
                            .tag(YearFilter.all_time)
                        ForEach(Array(years)) { year in
                            Text(year.description)
                                .tag(YearFilter.year(year: year))
                        }
                    }
                    .pickerStyle(.menu)
                }


                // TODO: Figure out a better experience for "story reels"
//                Spacer()
//
//                Reports(year: year) {
//                    Image(systemName: "play.fill")
//                }
            }

            NavigationStack {
                Picker("Filter by", selection: $categoryFilter) {
                    ForEach(Category.allCases, id: \.self) { filter in
                        Text(filter.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)

                ScrollView {
                    TagToggles(tags: $tagFilter)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10).fill(Color(uiColor: .secondarySystemBackground))
                        }

                    VStack {
                        switch categoryFilter {
                        case .author:
                            let dict = Dictionary(grouping: books, by: {
                                $0.author
                            })
                            AuthorGraphs(books: dict, year: $year)
                        case .series:
                            let dict = Dictionary(grouping: books, by: {
                                $0.series ?? "Standalones"
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
                            YearlyGraphs(books: dict, year: .year(currentYear))
                        }
                    }
                    .padding(.horizontal)
                    .tint(.primary)
                }
            }
            .animation(.linear, value: categoryFilter)
            .animation(.linear, value: tagFilter)
            .frame(maxWidth: .infinity)
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
                .filter{
                    if case let .year(year) = year {
                        return $0.year == year
                    } else {
                        return $0.year != .tbr && $0.year != .reading
                    }
                }
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
