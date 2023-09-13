//
//  AuthorGraphs.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/31/23.
//

import Charts
import Foundation
import SwiftUI

struct MostRead : View {
    let completed: [String:[BookCSVData]]

    var body: some View {
        let completed = completed
            .sorted(by: { $0.value.count > $1.value.count })

        let authorCounts = completed.flatMap{ author, books in
            [author:Double(books.count)]
        }
        
        let topFive = authorCounts.prefix(5)
        NavigationLink {
            BookList(data: completed, sectionTitle: { $0 }) { book in
                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.system(.title3))
                    if let series = book.series {
                        Text(series)
                            .font(.system(.caption))
                    }
                }
            }
        } label: {
            Graph(title: "Most Read", data: topFive, id: \.key) { author, count in
                let xp: PlottableValue = .value("Count", count)
                let yp: PlottableValue = .value("Author", author)
                BarMark(x: xp, y: yp, width: 10)
                    .annotation(position: AnnotationPosition.trailing) {
                        Text(String(Int(count)))
                    }
                    .foregroundStyle(by: yp)
            }
            .chartXAxis(.hidden)
            .frame(height: 250)
        }
    }
}

struct AuthorGraphs : View {
    @Environment(\.profileColor) private var profileColor
    
    let books: [String:[BookCSVData]]
    @Binding var year: YearFilter
    
    var completed: [String:[BookCSVData]] {
        books.mapValues{ $0.filter{
            if case let .year(year) = year {
                return $0.year == year
            } else {
                return $0.year != .tbr && $0.year != .reading
            }
        }}
        .filter{ !$1.isEmpty }
    }

    var body: some View {
        let completed = completed
            .sorted(by: { $0.value.count > $1.value.count })

        VStack {
            MostRead(completed: self.completed)
            
            let sortedByRating = completed.sorted(by: { first, second in
                let avg1 = first.value.reduce(0.0, { acc, book in
                    acc + Float(book.rating) / Float(first.value.count)
                })
                let avg2 = second.value.reduce(0.0, { acc, book in
                    acc + Float(book.rating) / Float(second.value.count)
                })
                return avg1 > avg2
            })
            let highestRated = sortedByRating.flatMap{ author, books in
                [author: Double(books.reduce(0.0, { acc, book in
                    acc + Float(book.rating) / Float(books.count)
                }))]
            }
            NavigationLink {
                BookList(data: Array(sortedByRating), sectionTitle: { $0 }) { book in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.system(.title3))
                            if let series = book.series {
                                Text(series)
                                    .font(.system(.caption))
                            }
                        }
                        Spacer()
                        StarRating(rating: .constant(book.rating))
                            .ratingStyle(SolidRatingStyle(color: profileColor))
                            .contentShape(Rectangle())
                            .fixedSize()
                    }
                }
            } label: {
                Graph(title: "Highest Rated", data: highestRated.prefix(5), id: \.key) { author, rating in
                    let xp: PlottableValue = .value("Author", author)
                    let yp: PlottableValue = .value("Rating", rating)
                    PointMark(x: yp, y: xp)
                        .symbolSize(rating * 150)
                        .annotation(position: .overlay) {
                            Text(String(format: "%0.1f", rating))
                                .font(.system(.caption))
                                .fixedSize()
                                .foregroundColor(.white)
                                .bold()
                        }
                        .foregroundStyle(by: xp)
                        .offset(y: -10)
                }
                .chartXAxis(.hidden)
                .frame(height: 250)
            }
        }
    }
}

struct AuthorGraphs_Previews : PreviewProvider {
    private struct PreviewWrapper : View {
        @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
        private var books: FetchedResults<BookCSVData>
        
        var body: some View {
            let dict = Dictionary(grouping: books, by: {
                $0.author
            })
            NavigationStack {
                AuthorGraphs(books: dict, year: .constant(.year(year: .year(2023))))
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
