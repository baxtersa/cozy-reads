//
//  GoalsView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct GoalsView : View {
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    @State private var current = 26

    let target = 50
    let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Goals")
                    .font(.system(.title))
                    .padding(.leading, 10)
                Text("Daily Tracker")
                    .font(.system(.title2))
                    .padding([.leading], 10)
                DailyGoalsView()
                Text("Monthly")
                    .font(.system(.title2))
                    .padding([.leading], 10)
                MonthlyGoalsView(yearlyTarget: target)
                Text("Yearly")
                    .font(.system(.title2))
                    .padding([.leading], 10)
                YearlyGoalsView(target: target, current: books.filter{$0.year == .year(currentYear)}.count)
                Spacer()
            }
        }
        .background(Color("BackgroundColor"))
    }
}

struct GoalsView_Previews : PreviewProvider {
    static var previews: some View {
        GoalsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
