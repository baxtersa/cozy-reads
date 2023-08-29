//
//  Reports.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/28/23.
//

import Foundation
import SwiftUI

private struct BooksRead : View {
    let year: Year
    let count: Int

    var body: some View {
        Text("You read \(count) books in \(year.description)")
    }
}

private struct AverageRating : View {
    let books: [BookCSVData]

    var averageRating: Float {
        books.reduce(0.0, { acc, book in
            acc + Float(book.rating) / Float(books.count)
        })
    }

    var body: some View {
        Text(String(format: "Average Rating: %0.2f stars", averageRating))
    }
}

private struct FavoriteBooks : View {
    @Environment(\.profileColor) private var profileColor

    let books: [BookCSVData]

    var body: some View {
        let topThree = books
            .sorted(by: { $0.rating > $1.rating })
            .prefix(3)

        VStack {
            let _ = print(topThree.map{$0.title})
            ForEach(topThree) { book in
                HStack {
                    VStack(alignment: .leading) {
                        Text(book.title)
                        Text("by \(book.author)")
                            .italic()
                    }
                    Spacer()
                    StarRating(rating: .constant(book.rating))
                        .ratingStyle(SolidRatingStyle(color: profileColor))
                        .fixedSize()
                }
            }
        }
    }
}

private struct MostReadAuthor : View {
    let books: [BookCSVData]
    
    var body: some View {
        if let mostRead = books
            .map({ $0.author })
            .reduce([String:Int](), { dict, author in
                dict.merging([author: 1], uniquingKeysWith: +)
            })
                .sorted(by: { $0.value > $1.value })
                .first {
            VStack {
                Text("Most read author: \(mostRead.key)")
                Text("\(mostRead.value) books")
            }
        }
    }
}

private struct DaysRead : View {
    let year: Year
    let daysRead: [ReadingTrackerEntity]
    
    var body: some View {
        if case let .year(num) = year {
            let daysThisYear = daysRead.filter{
                guard let date = $0.date else { return false }
                let components = Calendar.current.dateComponents([.year], from: date)
                return components.year == num
            }
            VStack {
                Text("\(daysThisYear.count) days read this year")
            }
        }
    }
}

private struct YearlyGoal : View {
    @FetchRequest(sortDescriptors: [])
    private var goals: FetchedResults<YearlyGoalEntity>

    let year: Year
    let books: [BookCSVData]

    var body: some View {
        if let thisYear = goals.first(where: { $0.targetYear == year }) {
            VStack {
                let target = thisYear.goal
                let read = books.count
                Text("Goal: \(target) books")
                Text("You read \(read) books in \(year.description)")
                if target > read {
                    Text(String(format: "You reached %0.0f%% of your goal for \(year.description)", 100*Float(read)/Float(target)))
                } else {
                    Text("Congratulations! You hit your reading goal for \(year.description)")
                }
            }
        } else {
            Text("You did not set a goal for \(year.description)")
        }
    }
}

struct YearlyReport : View {
    let year: Year
    let books: [BookCSVData]
    let daysRead: [ReadingTrackerEntity]
    
    var body: some View {
        Group {
            if books.isEmpty {
                BooksRead(year: year, count: books.count)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    Text("\(year.description): A year in review")
                        .font(.system(.title))
                    BooksRead(year: year, count: books.count)
                    AverageRating(books: books)
                    FavoriteBooks(books: books)
                    MostReadAuthor(books: books)
                    DaysRead(year: year, daysRead: daysRead)
                    YearlyGoal(year: year, books: books)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground)))
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .padding(.horizontal)
    }
}

struct AllTimeReport : View {
    let books: [BookCSVData]
    let daysRead: [ReadingTrackerEntity]

    var body: some View {
        VStack {
            Text("You have read \(books.count) books! Keep it going!")
        }
    }
}

enum ReportView : String, CaseIterable, Identifiable {
    case yearly = "Yearly"
    case all_time = "All-Time"
    
    var id: Self { self }
}

struct Reports : View {
    @Environment(\.profile) private var profile
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
    private var books: FetchedResults<BookCSVData>
    @FetchRequest(sortDescriptors: [])
    private var daysRead: FetchedResults<ReadingTrackerEntity>
    
    private let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023
    
    @State private var mode: ReportView = .yearly

    var body: some View {
        let books = books
            .filter{ $0.profile == profile.wrappedValue }
        let dict = Dictionary(grouping: books, by: \.year)
            .filter{
                guard case .year = $0.key else { return false }
                return true
            }
            .sorted(by: { $0.key > $1.key })

        VStack {
            ScrollView() {
                if mode == .yearly {
                    VStack(spacing: 20) {
                        ForEach(dict, id: \.key) { year, books in
                            YearlyReport(year: year, books: books, daysRead: Array(daysRead))
                        }
                    }
                } else {
                    AllTimeReport(books: books, daysRead: Array(daysRead))
                }
            }
            
            Picker("Report Mode", selection: $mode) {
                ForEach(ReportView.allCases) { mode in
                    Text(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
        }
    }
}

struct Reports_Previews : PreviewProvider {
    static var previews: some View {
        Reports()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
