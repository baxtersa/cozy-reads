//
//  DashboardView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct DashboardView : View {
    @Environment(\.profile) private var profile
 
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    private let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023
    @State private var overviewYear: Year = .year(Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023)

    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }
//        let _ = books.forEach { book in
//            if let profile = selectedProfile,
//               book.profile != profile {
//                book.profile = profile
//                PersistenceController.shared.save()
//            }
//        }
        let readThisYear = books.filter{$0.year == overviewYear}
        let booksRead = ChartModel(title: "Books read this year", metric: Float(readThisYear.count), symbol: "book")
        let avgRating = ChartModel(title: "Average rating", metric: readThisYear.reduce(0.0, { accum, book in
            accum + Float(book.rating)
        }) / Float(readThisYear.count), symbol: "star")

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack {
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
                }
                
                // TODO: Decide what to do about XP/Leveling System
                //                ProfileView()

//                if let profile = selectedProfile {
//                    Text("Books: \(readThisYear.count)")
//                    Text("Profile: \(profile.profile_books.map{$0.title}.description)")
//                    Text("Profile Books: \(profile.profile_books.count)")
//                }
                
                VStack(alignment: .leading) {
                    Text("Progress")
                        .font(.system(.title2))
                        .padding(.leading)
                    ChartView(chart: booksRead)
                    ChartView(chart: avgRating)
                }
                CurrentlyReadingView()
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
