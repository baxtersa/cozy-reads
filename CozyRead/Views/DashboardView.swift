//
//  DashboardView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct Overview : View {
    @Environment(\.profile) private var profile
    @Environment(\.profileColor) private var profileColor

    let years: [Year]
    @Binding var overviewYear: Year

    var body: some View {
        HStack {
            Text("Overview")
                .font(.system(.title))
                .padding(.leading, 10)
            
            Spacer()
            Picker("Year", selection: $overviewYear) {
                ForEach(years) { year in
                    Text(year.description)
                }
            }
            .tint(profileColor)
            .foregroundColor(profileColor)
        }
        .onChange(of: profileColor) { value in
            print("color changed", value.description)
        }
    }
}

struct DashboardView : View {
    @Environment(\.profile) private var profile
    @Environment(\.profileColor) private var profileColor

    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    private let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023
    @State private var overviewYear: Year = .year(Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023)

    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }
        let readThisYear = books.filter{$0.year == overviewYear}
        let booksRead = ChartModel(title: "Books read this year", metric: Float(readThisYear.count), symbol: "book")
        let avgRating = ChartModel(title: "Average rating", metric: readThisYear.reduce(0.0, { accum, book in
            accum + Float(book.rating)
        }) / Float(readThisYear.count), symbol: "star")

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack {
                    let years = Array(Set(books.map{ $0.year }.filter{
                        if case .year = $0 {
                            return true
                        } else {
                            return false
                        }
                    })).sorted()

                    Overview(years: years, overviewYear: $overviewYear)
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
//            .profileColor(.indigo)
//            .tint(.indigo)
 
    }
}
