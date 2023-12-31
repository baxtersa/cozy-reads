//
//  GenreGraphs.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/31/23.
//

import Charts
import Foundation
import SwiftUI

struct GenreGraphs : View {
    @Environment(\.profileColor) private var profileColor

    let books: [Genre:[BookCSVData]]

    @Binding var year: YearFilter

    var body: some View {
        let completed = books.sorted(by: { $0.value.count > $1.value.count }).filter{ !$1.isEmpty }
        let data = completed.flatMap{ genre, books in
            [genre:Double(books.count)]
        }

        VStack {
            NavigationLink {
                BookList(data: Array(completed), sectionTitle: { $0.rawValue }) { book in
                    VStack(alignment: .leading) {
                        Text(book.title)
                            .font(.system(.title3))
                        HStack {
                            if let series = book.series {
                                Text(series)
                                    .font(.system(.caption))
                            }
                            Spacer()
                            Text("by \(book.author)")
                                .font(.system(.footnote))
                                .italic()
                        }
                    }
                }
            } label: {
                Graph(title: "Books Read", data: data.prefix(5), id: \.key, isLink: true) { genre, count in
                    let xp: PlottableValue = .value("Genre", genre.rawValue)
                    let yp: PlottableValue =  .value("Books Read", count)
                    BarMark(x: yp, y: xp)
                        .foregroundStyle(by: xp)
                        .annotation(position: .trailing) {
                            Text(String(Int(count)))
                        }
                }
                .chartXAxis(.hidden)
                .frame(height: 250)
            }

            NavigationLink {
                BookList(data: completed, sectionTitle: { $0.rawValue }) { book in
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
                Graph(title: "Average Rating", data: completed.prefix(5), id: \.key, isLink: true) { genre, books in
                    let avg = books.reduce(0, { acc, book in
                        acc + Float(book.rating) / Float(books.count)
                    })
                    let xp: PlottableValue = .value("Genre", genre.rawValue)
                    let yp: PlottableValue =  .value("Rating", avg)
                    PointMark(x: yp, y: xp)
                        .symbolSize(CGFloat(avg) * 150)
                        .annotation(position: .overlay) {
                            Text(String(format: "%0.1f", avg))
                                .font(.system(.caption))
                                .fixedSize()
                                .foregroundColor(.white)
                                .bold()
                        }
                        .foregroundStyle(by: xp)
                        .offset(y: -10)
                }
                .chartXAxis(.hidden)
            }

            let allBooks: [BookCSVData] = completed.flatMap{$1}
            let tags: [String] = Array(Set(books.flatMap{$1.flatMap{$0.tags}}))
            let tagCounts  = tags.map{ tag in
                (tag, allBooks.filter{ $0.tags.contains(tag) }.count)
            }.filter{ $0.1 > 0 }
                .sorted(by: { $0.1 > $1.1 })

            NavigationLink {
                let tagBooks = tags.map { tag in
                    (tag, allBooks.filter{ $0.tags.contains(tag) })
                }
                    .sorted(by: { $0.1.count > $1.1.count })

                BookList(data: tagBooks, sectionTitle: { $0 }) { book in
                    VStack(alignment: .leading) {
                        Text(book.title)
                            .font(.system(.title3))
                        HStack {
                            if let series = book.series {
                                Text(series)
                                    .font(.system(.caption))
                            }
                            Spacer()
                            Text("by \(book.author)")
                                .font(.system(.footnote))
                                .italic()
                        }
                    }
                }
            } label: {
                Graph(title: "Tags", data: tagCounts.prefix(5), id: \.0, isLink: true) { (tag, count) in
                    let xp: PlottableValue = .value("Tag", tag)
                    let yp: PlottableValue =  .value("Books Read", count)
                    
                    BarMark(x: yp, y: xp)
                        .foregroundStyle(by: xp)
                        .annotation(position: .trailing) {
                            Text(String(Int(count)))
                        }
                }
                .chartXAxis(.hidden)
                .frame(height: 250)
            }
        }
    }
}

struct GenreGraphs_Previews : PreviewProvider {
    private struct PreviewWrapper : View {
        @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
        private var books: FetchedResults<BookCSVData>
        
        var body: some View {
            let dict = Dictionary(grouping: books, by: {
                $0.genre
            })
            NavigationStack {
                GenreGraphs(books: dict, year: .constant(.year(year: .year(2023))))
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
