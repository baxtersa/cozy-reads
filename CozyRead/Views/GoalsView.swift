//
//  GoalsView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct GoalsView : View {
    @Environment(\.profile) private var profile
 
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    @FetchRequest(sortDescriptors: []) private var yearlyGoals: FetchedResults<YearlyGoalEntity>

    private let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023
    @State private var selectedYear: Year = .year(Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023)

    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }.filter{ $0.year == selectedYear}
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Goals")
                        .font(.system(.title))
                    Spacer()
                    let years = Array(Set(self.books.map{ $0.year }.filter{
                        if case .year = $0 {
                            return true
                        } else {
                            return false
                        }
                    })).sorted()
                    Picker("Year", selection: $selectedYear) {
                        ForEach(Array(years)) { year in
                            Text(year.description)
                        }
                    }
                    .pickerStyle(.menu)
//                    XPProgressView()
//                        .xpProgressStyle(.badge)
                }
                .padding(.horizontal)
                if selectedYear == .year(currentYear) {
                    Text("Daily")
                        .font(.system(.title2))
                        .padding([.leading])
                    DailyGoalsView()
                }
                Text("Monthly")
                    .font(.system(.title2))
                    .padding([.leading])
                if let target = yearlyGoals.first(where: { $0.targetYear == selectedYear }) {
                    MonthlyGoalsView(yearlyTarget: target.goal)
                } else {
                    MonthlyGoalsTemplate()
                }
                Text("Yearly")
                    .font(.system(.title2))
                    .padding([.leading])
                if let target = yearlyGoals.first(where: { $0.targetYear == selectedYear }) {
                    YearlyGoalsView(target: target, current: books.count)
                } else {
                    if case let .year(num) = selectedYear {
                        CreateYearlyGoal(year: num)
                    }
                }
                Spacer()
            }
        }
    }
}

struct GoalsView_Previews : PreviewProvider {
    static var previews: some View {
        GoalsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
