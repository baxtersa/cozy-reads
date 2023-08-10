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
    let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023

    var body: some View {
        let readThisYear = books.filter{$0.year == .year(currentYear)}
        let booksRead = Chart(title: "Books read", metric: Float(readThisYear.count), symbol: "book")
        let avgRating = Chart(title: "Average rating", metric: readThisYear.reduce(0.0, { accum, book in
            accum + Float(book.rating)
        }) / Float(readThisYear.count), symbol: "star")

        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Overview")
                    .font(.system(.title))
                    .padding(.leading, 10)
                ChartView(chart: booksRead)
                ChartView(chart: avgRating)
                Text("Currently Reading")
                    .font(.system(.title2))
                    .padding(.horizontal, 10)
                CurrentlyReadingView()
                Spacer()
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
