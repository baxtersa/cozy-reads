//
//  DashboardView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct DashboardView : View {
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    private let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023
    @State private var overviewYear: Year = .year(Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023)

    var body: some View {
        let readThisYear = books.filter{$0.year == overviewYear}
        let booksRead = ChartModel(title: "Books read this year", metric: Float(readThisYear.count), symbol: "book")
        let avgRating = ChartModel(title: "Average rating", metric: readThisYear.reduce(0.0, { accum, book in
            accum + Float(book.rating)
        }) / Float(readThisYear.count), symbol: "star")

        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Overview")
                        .font(.system(.title))
                        .padding(.leading, 10)

                    Spacer()
                    let years = Array(Set(books.map{ $0.year }.filter{
                        if case .year = $0 {
                            return true
                        } else {
                            return false
                        }
                    })).sorted()
                    Picker("Year", selection: $overviewYear) {
                        ForEach(Array(years)) { year in
                            Text(year.description)
                        }
                    }
                    .pickerStyle(.menu)
                }
                ChartView(chart: booksRead)
                ChartView(chart: avgRating)
                Text("Currently Reading")
                    .font(.system(.title2))
                    .padding(.horizontal, 10)
                CurrentlyReadingView()
            }
        }
        .background(Color("BackgroundColor"))
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
