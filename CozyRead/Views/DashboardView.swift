//
//  DashboardView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct DashboardView : View {
    private let booksRead = Chart(title: "Books read", metric: 24, symbol: "book")
    private let avgRating = Chart(title: "Average rating", metric: 3.8, symbol: "star")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overview")
                .font(.system(.title))
                .padding([.horizontal, .top], 10)
            ChartView(chart: booksRead)
            ChartView(chart: avgRating)
            Text("Currently Reading")
                .font(.system(.title2))
                .padding(.horizontal, 10)
            CurrentlyReadingView()
            Text("To Be Read")
                .font(.system(.title2))
                .padding([.horizontal, .bottom], 10)
            Spacer()
        }
        .background(Color("BackgroundColor"))
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
