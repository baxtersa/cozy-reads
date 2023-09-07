//
//  BooksReadView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct ChartModel {
    let title: String
    let metric: Float
    let symbol: String
}

struct ChartView : View {
    @Environment(\.profileColor) private var profileColor

    let chart: ChartModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(chart.title)
                    .font(.system(.title3))
                    .italic()
                let formatter = NumberFormatter()
                let _ = formatter.minimumFractionDigits = 0
                let _ = formatter.maximumFractionDigits = 2
                Text(formatter.string(from: chart.metric as NSNumber) ?? "0")
                    .font(.system(.title, weight: .bold))
                    .padding(.leading)
                    .foregroundColor(profileColor)
            }
            .padding(.leading)
            .padding(.vertical)
            Spacer()
            Image(systemName: chart.symbol)
                .font(.largeTitle)
                .padding(.trailing)
                .foregroundColor(profileColor)
        }
        .background(Color(uiColor: .systemBackground))
//        .background {
//            ZStack(alignment: .top) {
//                Rectangle()
//                    .fill(Color(uiColor: .systemBackground))
//                Rectangle()
//                    .frame(maxHeight: 10)
//                    .foregroundColor(profileColor)
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//        }
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct ChartView_Previews: PreviewProvider {
    static let chart = ChartModel(title: "Books read this year", metric: 24, symbol: "book")
    static let star = ChartModel(title: "Average rating", metric: 3.876543, symbol: "star")
    static var previews: some View {
        VStack {
            ChartView(chart: chart)
            ChartView(chart: star)
        }
    }
}
