//
//  DashboardView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct Overview : View {
    let years: [Year]
    @Binding var overviewYear: YearFilter

    var body: some View {
        HStack {
            Text("Overview")
                .font(.system(.title))
                .padding(.leading)
                .bold()
            
            Spacer()
            Picker("Year", selection: $overviewYear) {
                Text("All-Time")
                    .tag(YearFilter.all_time)
                ForEach(Array(years)) { year in
                    Text(year.description)
                        .tag(YearFilter.year(year: year))
                }
//
//                ForEach(years.filter{
//                    guard case .year = $0 else { return false }
//                    return true
//                }) { year in
//                    Text(year.description)
//                }
            }
        }
    }
}

struct DashboardView : View {
    @Environment(\.profile) private var profile
    @Environment(\.profileColor) private var profileColor

    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    private let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023
    @State private var overviewYear: YearFilter = .year(year: .year(Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023))

    var body: some View {
        let books = books
            .filter{ $0.profile == profile.wrappedValue }

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                let readYears = books.map{ $0.year }
                let years = Array(Set(readYears + [.year(currentYear)])).sorted()
                
                // TODO: Decide what to do about XP/Leveling System
                //                ProfileView()
                
                //                    ReadTodayView()

                VStack {
                    Overview(years: years, overviewYear: $overviewYear)
                                    
                    DynamicStack {
                        DailyGoalsView()

                        TotalsGraphs(books: books, year: $overviewYear)
                        .padding(.horizontal)

                        if case let .year(year) = overviewYear {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                Divider()
                            }
                            ReadingProgress(year: year)
                        }
                    }
                }
                CurrentlyReadingView()
                TBR()
                Spacer(minLength: 50)
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
