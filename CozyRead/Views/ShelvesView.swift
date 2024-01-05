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
//    case totals
    case author
    case series
    case genre
    case year
}

enum YearFilter: Hashable {
    case all_time
    case year(year: Year)
}

struct Totals : View {
    let books: [BookCSVData]
    let daysRead: [Date]

    var body: some View {
        let bookTotal = books.count
        let authorTotal = Dictionary(grouping: books, by: { $0.author }).keys.count
        let seriesTotal = Dictionary(grouping: books, by: { $0.series }).keys.filter{ !($0?.isEmpty ?? true) }.count
        let genreTotal = Dictionary(grouping: books, by: { $0.genre }).keys.count
        let daysRead = daysRead.count

        VStack {
            Text("Totals")
                .font(.system(.title2))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                VStack {
                    Divider()
                    
                    ZStack {
                        Text("\(bookTotal)")
                            .bold()
                            .font(.system(size: 80))
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leadingLastTextBaseline)

                        HStack {
                            Image(systemName: "book")
                                .font(.system(.caption))
                            Text("books")
                                .font(.system(.caption2))
                        }
                        .padding(.horizontal, 5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                }
                
                VStack(alignment: .leading) {
                    Divider()

                    HStack {
                        Image(systemName: "person")
                            .font(.system(.caption))
                            .frame(width: 5)
                            .padding(.horizontal, 5)
                        
                        Text("\(authorTotal)")
                        Spacer()
                        Text("authors")
                            .font(.system(.caption2))
                            .frame(maxHeight: .infinity, alignment: .top)
                    }

                    Divider()

                    HStack {
                        Image(systemName: "books.vertical")
                            .font(.system(.caption))
                            .frame(width: 5)
                            .padding(.horizontal, 5)
                        Text("\(seriesTotal)")
                        Spacer()
                        Text("series")
                            .font(.system(.caption2))
                            .frame(maxHeight: .infinity, alignment: .top)
                    }

                    Divider()

                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(.caption))
                            .frame(width: 5)
                            .padding(.horizontal, 5)
                        Text("\(genreTotal)")
                        Spacer()
                        Text("genres")
                            .font(.system(.caption2))
                            .frame(maxHeight: .infinity, alignment: .top)
                    }
                    
                    if daysRead != 0 {
                        Divider()
                        
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(.caption))
                                .frame(width: 5)
                                .padding(.horizontal, 5)
                            Text("\(daysRead)")
                            Spacer()
                            Text("days read")
                                .font(.system(.caption2))
                                .frame(maxHeight: .infinity, alignment: .top)
                        }
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
        }
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct Favorites: View {
    @Environment(\.profileColor) private var profileColor

    @State private var expandBooks: Bool = false
    @State private var expandAuthors: Bool = false
    @State private var expandSeries: Bool = false

    let books: [BookCSVData]

    var body: some View {
        let favoriteBooks = books.filter{ $0.rating == 5 }
        let favoriteAuthors = Dictionary(grouping: books, by: { $0.author })
            .mapValues { books in
                books.reduce(0.0, { acc, book in
                    acc + Float(book.rating) / Float(books.count)
                })
            }
            .sorted(by: { $0.value > $1.value })
        let favoriteSeries = Dictionary(grouping: books, by: { $0.series })
            .mapValues { books in
                books.reduce(0.0, { acc, book in
                    acc + Float(book.rating) / Float(books.count)
                })
            }
            .sorted(by: { $0.value > $1.value })

//        let sortedByRating = books.sorted(by: { first, second in
//                let avg1 = first.value.reduce(0.0, { acc, book in
//                    acc + Float(book.rating) / Float(first.value.count)
//                })
//                let avg2 = second.value.reduce(0.0, { acc, book in
//                    acc + Float(book.rating) / Float(second.value.count)
//                })
//                return avg1 > avg2
//            })
//            let highestRated = sortedByRating.flatMap{ author, books in
//                [author: Double(books.reduce(0.0, { acc, book in
//                    acc + Float(book.rating) / Float(books.count)
//                }))]
//            }

        VStack {
            Text("Favorites")
                .font(.system(.title2))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading) {
                VStack {
                    HStack {
                        Image(systemName: "book")
                            .font(.system(.body))
                            .frame(width: 5)
                            .padding(.horizontal, 5)
                        Text("book")
                            .font(.system(.caption))
                        
                        Spacer()
                        
                        Text(favoriteBooks.first?.title ?? "None")
                            .lineLimit(1)
                        if favoriteBooks.count > 1 {
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(expandBooks ? 0 : -90))
                        }
                    }
                    
                    if expandBooks && favoriteBooks.count > 1 {
                        ForEach(favoriteBooks.dropFirst()) { book in
                            HStack {
                                Spacer()
                                
                                Text(book.title)
                                    .lineLimit(1)
                                Image(systemName: "chevron.right")
                                    .hidden()
                            }
                        }
                    }
                }
                .onTapGesture(perform: {
                    withAnimation {
                        expandBooks.toggle()
                    }
                })

                Divider()

                VStack {
                    let tied = favoriteAuthors.prefix(while: { $0.value == (favoriteAuthors.first?.value ?? 5) })
                    HStack {
                        Image(systemName: "person")
                            .font(.system(.body))
                            .frame(width: 5)
                            .padding(.horizontal, 5)
                        Text("author")
                            .font(.system(.caption))
                        
                        Spacer()
                        
                        Text(tied.first?.key ?? "None")
                        if tied.count > 1 {
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(expandAuthors ? 0 : -90))
                        }
                    }
                    
                    if expandAuthors && tied.count > 1 {
                        ForEach(tied.dropFirst(), id: \.key) { author, rating in
                            HStack {
                                Spacer()
                                
                                Text(author)
                                    .lineLimit(1)
                                Image(systemName: "chevron.right")
                                    .hidden()
                            }
                        }
                    }
                }
                .onTapGesture(perform: {
                    withAnimation {
                        expandAuthors.toggle()
                    }
                })

                Divider()

                VStack {
                    let tied = favoriteSeries.prefix(while: { $0.value == (favoriteSeries.first?.value ?? 5) })
                    HStack {
                        Image(systemName: "books.vertical")
                            .font(.system(.body))
                            .frame(width: 5)
                            .padding(.horizontal, 5)
                        Text("series")
                            .font(.system(.caption))
                        
                        Spacer()
                        
                        Text(tied.first?.key ?? "None")
                        if tied.count > 1 {
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(expandSeries ? 0 : -90))
                        }
                    }
                    
                    if expandSeries && tied.count > 1 {
                        ForEach(tied.dropFirst(), id: \.key) { series, rating in
                            HStack {
                                Spacer()

                                Text(series ?? "Unknown")
                                    .lineLimit(1)
                                Image(systemName: "chevron.right")
                                    .hidden()
                            }
                        }
                    }
                }
                .onTapGesture(perform: {
                    withAnimation {
                        expandSeries.toggle()
                    }
                })
            }
            .padding(.top)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
        }
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct TotalsGraphs: View {
    @Environment(\.profile) private var profile

    let books: [BookCSVData]
    @Binding var year: YearFilter

    @FetchRequest(sortDescriptors: [])
    private var daysRead: FetchedResults<ReadingTrackerEntity>

    var completed: [BookCSVData] {
        books.filter{
            if case let .year(year) = year {
                return $0.year == year
            } else {
                return $0.year != .tbr && $0.year != .reading
            }
        }
    }

    var body: some View {
        let activity = daysRead
            .filter{ $0.profile == profile.wrappedValue }
            .compactMap{ $0.date }
            .filter{ date in
                guard let activityYear = Calendar.current.dateComponents([.year], from: date).year else { return false }
                if case let .year(year) = year {
                    guard case let .year(year) = year else { return false }
                    return activityYear == year
                } else {
                    return true
                }
            }
        VStack {
            Totals(books: completed, daysRead: activity)
//
//            Favorites(books: completed)
        }
    }
}

struct ShelvesView : View {
    static private let defaultCategory = "default_category"
    
    @Environment(\.profile) private var profile

    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var fetched: FetchedResults<BookCSVData>

    private let currentYear = Calendar.current.dateComponents([.year], from: .now).year ?? 2023

    @State private var year: YearFilter = .year(year:  .year(Calendar.current.dateComponents([.year], from: .now).year ?? 2023))
    @State private var tagFilter: [TagToggles.ToggleState] = []

    @AppStorage(ShelvesView.defaultCategory) private var categoryFilter: Category = .year

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let books = fetched
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
                    let readYears = fetched
                        .filter{ $0.profile == profile.wrappedValue }
                        .map{ $0.year }
                    let years: [Year] = Array(Set(readYears + [.year(currentYear)])).sorted()
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
                        let filtered = books.filter{
                            if case let .year(year) = year {
                                return $0.year == year
                            } else {
                                return $0.year != .tbr && $0.year != .reading
                            }
                        }

                        switch categoryFilter {
//                        case .totals:
//                            TotalsGraphs(books: books, year: $year)
                        case .author:
                            let dict = Dictionary(grouping: filtered, by: {
                                $0.author
                            })
                            AuthorGraphs(books: dict, year: $year)
                        case .series:
                            let dict = Dictionary(grouping: filtered, by: {
                                $0.series ?? "Standalones"
                            })
                            AuthorGraphs(books: dict, year: $year)
                        case .genre:
                            let dict = Dictionary(grouping: filtered, by: {
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
            tagFilter = Array(Set(fetched
                .flatMap{ $0.tags }))
            .map{ tag in
                TagToggles.ToggleState(tag: tag, state: !fetched.filter{
                    $0.tags.contains(tag)
                }.isEmpty)
            }
        }
        .onChange(of: categoryFilter) { _ in
            tagFilter = Array(Set(fetched
                .filter{
                    if case let .year(year) = year {
                        return $0.year == year
                    } else {
                        return $0.year != .tbr && $0.year != .reading
                    }
                }
                .flatMap{ $0.tags }))
            .map{ tag in
                TagToggles.ToggleState(tag: tag, state: !fetched.filter{
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
