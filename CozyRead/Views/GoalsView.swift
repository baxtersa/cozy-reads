//
//  GoalsView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct GoalsView : View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Goals")
                    .font(.system(.title))
                    .padding([.horizontal, .top], 10)
                Text("Daily Tracker")
                    .font(.system(.title2))
                    .padding([.leading], 10)
                DailyGoalsView()
                Text("Monthly")
                    .font(.system(.title2))
                    .padding([.leading], 10)
                MonthlyGoalsView(yearlyTarget: 50)
                Text("Yearly")
                    .font(.system(.title2))
                    .padding([.leading], 10)
                YearlyGoalsView(target: 50, current: 26)
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
