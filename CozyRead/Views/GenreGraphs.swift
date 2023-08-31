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

    var completed: [Genre:[BookCSVData]] {
        books.mapValues{ $0.filter{ $0.year == year } }
    }

    @Binding var year: Year

    var body: some View {
        let completed = completed.sorted(by: { $0.key < $1.key }).filter{ !$1.isEmpty }
        let data = completed.flatMap{ genre, books in
            [genre:Double(books.count)]
        }

        VStack {
            NavigationLink {
                List(completed, id: \.key) { genre, books in
                    Section(genre.rawValue) {
                        ForEach(books) { book in
                            Text(book.title)
                        }
                    }
                }
            } label: {
                Graph(title: "Books Read", data: data, id: \.key) { genre, count in
                    let xp: PlottableValue = .value("Genre", genre.rawValue)
                    let yp: PlottableValue =  .value("Books Read", count)
                    BarMark(x: xp, y: yp)
                        .foregroundStyle(by: xp)
                        .annotation {
                            Text(String(Int(count)))
                        }
                }
            }

            NavigationLink {
                List(completed, id: \.key) { genre, books in
                    Section(genre.rawValue) {
                        ForEach(books) { book in
                            HStack {
                                Text(book.title)
                                Spacer()
                                StarRating(rating: .constant(book.rating))
                                    .ratingStyle(SolidRatingStyle(color: profileColor))
                                    .fixedSize()
                            }
                        }
                    }
                }
            } label: {
                Graph(title: "Average Rating", data: completed, id: \.key) { genre, books in
                    let avg = books.reduce(0, { acc, book in
                        acc + Float(book.rating) / Float(books.count)
                    })
                    let xp: PlottableValue = .value("Genre", genre.rawValue)
                    let yp: PlottableValue =  .value("Rating", avg)
                    PointMark(x: xp, y: yp)
                        .symbolSize(CGFloat(books.count) * 150)
                        .annotation(position: .overlay) {
                            Text(String(format: "%0.1f", avg))
                                .font(.system(.caption))
                                .fixedSize()
                                .foregroundColor(.white)
                                .bold()
                        }
                        .foregroundStyle(by: xp)
                }
            }

            let allBooks: [BookCSVData] = completed.flatMap{$1}
            let tags: [String] = Array(Set(books.flatMap{$1.flatMap{$0.tags}}))
            let tagCounts  = tags.map{ tag in
                (tag, allBooks.filter{ $0.tags.contains(tag) }.count)
            }.sorted(by: { $0.1 < $1.1 })

            NavigationLink {
                let tagBooks = tags.map { tag in
                    (tag, allBooks.filter{ $0.tags.contains(tag) })
                }
                List(tagBooks, id: \.0) { tag, books in
                    Section(tag) {
                        ForEach(books) { book in
                            Text(book.title)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            } label: {
                Graph(title: "Tags", data: tagCounts, id: \.0) { (tag, count) in
                    let xp: PlottableValue = .value("Tag", tag)
                    let yp: PlottableValue =  .value("Books Read", count)
                    
                    if #available(iOS 17.0, *) {
                    } else {
                        BarMark(x: xp, y: yp)
                            .foregroundStyle(by: xp)
                            .annotation {
                                Text(String(Int(count)))
                            }
                    }
                }
            }
        }
    }
}

struct GenreGrapsh_Previews : PreviewProvider {
    private struct PreviewWrapper : View {
        @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
        private var books: FetchedResults<BookCSVData>
        
        var body: some View {
            let dict = Dictionary(grouping: books, by: {
                $0.genre
            })
            NavigationStack {
                GenreGraphs(books: dict, year: .constant(.year(2023)))
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
