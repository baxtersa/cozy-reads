//
//  YearlyGraphs.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/31/23.
//

import Charts
import Foundation
import SwiftUI

struct MonthlyProgress : View {
    @Environment(\.profile) private var profile

    @FetchRequest(sortDescriptors: [])
    private var goals: FetchedResults<YearlyGoalEntity>

    let books: [Year:[BookCSVData]]
    let year: Year

    @ViewBuilder var subtitle: some View {
        let thisYear = books
            .filter{ $0.key == year }
            .flatMap{ $0.value }
            .compactMap{ $0.dateCompleted }
        if let goal = goal {
            Text("\(thisYear.count)/\(goal.goal) books")
        } else {
            Text("\(thisYear.count) books")
        }
    }
    
    private var goal: YearlyGoalEntity? {
        goals.filter{ $0.profile == profile.wrappedValue }.first{ $0.targetYear == year }
    }

    var body: some View {
        let thisYear = (books.first{$0.key == year}.map{$0.value} ?? [])
            .filter{$0.dateCompleted != nil}
        let dict = Dictionary(grouping: thisYear, by: {
            Calendar.current.dateComponents([.month, .year], from: $0.dateCompleted ?? .now)
        })
            .filter{ $0.key.month != nil }
            .sorted(by: {$0.key.month ?? 0 > $1.key.month ?? 0})
 
        if case let .year(num) = year,
           let startDate = Calendar.current.date(from: DateComponents(year: num)),
           let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: startDate),
           let endDate = Calendar.current.date(byAdding: .day, value: -1, to: nextYear) {
            NavigationLink {
                BookList(data: dict, sectionTitle: { component in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM"
                    guard let month = Calendar.current.date(from: component) else { return "Unknown" }
                    return dateFormatter.string(from: month)
                }) { book in
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
                Graph(title: "\(year.description) Progress", subtitle: subtitle.padding(.leading), data: dict, id: \.key, isLink: true) { components, books in
                    if let date = Calendar.current.date(from: components) {
                        let xp: PlottableValue = .value("Month", date, unit: .month)
                        let count = thisYear.reduce(0, { acc, book in
                            if let dateCompleted = book.dateCompleted,
                               let completed = Calendar.current.dateComponents([.month], from: dateCompleted).month,
                               let current = components.month,
                               completed < current {
                                return acc + 1
                            } else {
                                return acc
                            }
                        })
                        let yp: PlottableValue =  .value("Books Read", count)
                        LineMark(x: xp, y: yp)
                            .interpolationMethod(.catmullRom)

                        if let goal = goal {
                            LineMark(x: .value("Month", startDate, unit: .month), y: .value("Trend", 0))
                                .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [20]))
                                .lineStyle(by: .value("Trend", 0))
                            LineMark(x: .value("Month", endDate, unit: .month), y: .value("Trend", goal.goal))
                                .lineStyle(by: .value("Trend", 0))
                        }
                    }
                }
                .chartXScale(domain: [startDate, endDate])
            }
        }
    }
}

struct ReadingActivity: View {
    @Environment(\.profile) private var profile

    @FetchRequest(sortDescriptors: [])
    private var activity: FetchedResults<ReadingTrackerEntity>
    
    let year: Year

    var body: some View {
        let activity = activity
            .filter{ $0.profile == profile.wrappedValue }
            .compactMap{ $0.date }
            .filter{ date in
                guard let activityYear = Calendar.current.dateComponents([.year], from: date).year else { return false }
                guard case let .year(year) = year else { return false }
                return activityYear == year
            }
        let dict = Dictionary(grouping: activity, by: {
            Calendar.current.dateComponents([.month, .year], from: $0)
        })
            .sorted(by: { $0.key.month ?? 0 > $1.key.month ?? 0 })

        if case let .year(num) = year,
           let startDate = Calendar.current.date(from: DateComponents(year: num)),
           let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: startDate),
           let endDate = Calendar.current.date(byAdding: .day, value: -1, to: nextYear) {
            Graph(title: "Reading Activity", data: dict, id: \.key) { month, activities in
                if let month = Calendar.current.date(from: month) {
                    let xp: PlottableValue = .value("Month", month, unit: .month)
                    let ypStart: PlottableValue = .value("Days Read", -activities.count)
                    let ypEnd: PlottableValue = .value("Days Read", activities.count)
                    RectangleMark(x: xp, yStart: ypStart, yEnd: ypEnd)
                        .cornerRadius(10)
                }
            }
            .chartXScale(domain: [startDate, endDate])
            .chartYAxis(.hidden)
            .chartYScale(domain: [-31,31])
        }
    }
}

struct YearlyGraphs : View {
    let books: [Year:[BookCSVData]]
    let year: Year
    
    var completed: [Year:[BookCSVData]] {
        books.filter { $0.key != .reading && $0.key != .tbr }
    }
    var rate: Float? {
        let data = completed.sorted(by: { $0.key < $1.key }).flatMap{ year, books in
            [year:Double(books.count)]
        }
        
        // Make sure we have enough data to compute a rate of change with
        guard data.count >= 2 else {
            return nil
        }

        let lastTwoYears = data.dropFirst(data.count - 2)
        var rate: Float?
        if let lastYear = lastTwoYears.first,
           let thisYear = lastTwoYears.last,
           lastYear.key != thisYear.key {
            rate = (Float(thisYear.value) / Float(lastYear.value) - 1) * 100
        }
        return rate
    }
    
    @ViewBuilder var yearOverYear: (some View)? {
        if let rate = rate {
            HStack {
                Text(String(format: "%0.2f%%", rate))
                let direction = rate >= 0 ? "arrow.up" : "arrow.down"
                Image(systemName: direction)
            }
            .foregroundColor(rate >= 0 ? .green : .red)
        } else {
            EmptyView()
        }
    }

    @State private var appear: Bool = false

    var body: some View {
        let completed = books.filter { $0.key != .reading && $0.key != .tbr }.sorted(by: { $0.key < $1.key })
        let data = completed.flatMap{ year, books in
            [year:Double(books.count)]
        }

        VStack {
            MonthlyProgress(books: books, year: year)

            ReadingActivity(year: year)

            Graph(title: "Books Read", subtitle: {
                HStack {
                    yearOverYear

                    Spacer()

                    Text("All-time: \(completed.compactMap{ $1.count }.reduce(0, { acc, count in acc + count }))")
                    Image(systemName: "book")
                }
                .padding(.horizontal)
            }(), data: data, id: \.key) { year, count in
                let xp: PlottableValue = .value("Year", year.description)
                let yp: PlottableValue =  .value("Books Read", count)
                LineMark(x: xp, y: yp)
                    .interpolationMethod(.catmullRom)
            }
            
            Graph(title: "Average Rating", data: completed, id: \.key) { year, books in
                let avg = books.reduce(0, { acc, book in
                    acc + Float(book.rating) / Float(books.count)
                })
                let xp: PlottableValue = .value("Year", year.description)
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
    }
}

struct YearlyGraphs_Previews : PreviewProvider {
    private struct PreviewWrapper : View {
        @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
        private var books: FetchedResults<BookCSVData>
        
        var body: some View {
            let dict = Dictionary(grouping: books, by: {
                $0.year
            })
            NavigationStack {
                YearlyGraphs(books: dict, year: .year(2023))
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
