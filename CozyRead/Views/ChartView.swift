//
//  BooksReadView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct Chart {
    let title: String
    let metric: Float
    let symbol: String
}

struct ChartView : View {
    let chart: Chart

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(chart.title)
                    .font(.system(.title3))
                Text(chart.metric.formatted())
                    .font(.system(.title, weight: .bold))
                    .padding(.leading)
            }
            .padding(.leading)
            .padding(.vertical)
            Spacer()
            Image(systemName: chart.symbol)
                .font(.largeTitle)
                .padding(.trailing)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.white))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct ChartView_Previews: PreviewProvider {
    static let chart = Chart(title: "Books read this year", metric: 24, symbol: "book")
    static let star = Chart(title: "Average rating", metric: 3.8, symbol: "star")
    static var previews: some View {
        VStack {
            ChartView(chart: chart)
            ChartView(chart: star)
        }
    }
}
