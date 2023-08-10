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
                    .italic()
                let formatter = NumberFormatter()
                let _ = formatter.minimumFractionDigits = 0
                let _ = formatter.maximumFractionDigits = 2
                Text(formatter.string(from: chart.metric as NSNumber) ?? "0")
                    .font(.system(.title, weight: .bold))
                    .padding(.leading)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .topTrailing))
            }
            .padding(.leading)
            .padding(.vertical)
            Spacer()
            Image(systemName: chart.symbol)
                .font(.largeTitle)
                .padding(.trailing)
                .foregroundStyle(Gradient(colors: [.blue, .purple]))
        }
        .background {
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(.white)
                Rectangle()
                    .frame(maxHeight: 10)
                    .foregroundStyle(LinearGradient(gradient: Gradient( colors: [.blue, .purple, .purple, .clear, .clear, .clear]), startPoint: .leading, endPoint: .topTrailing))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .cornerRadius(10)
        .padding(.horizontal, 10)
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct ChartView_Previews: PreviewProvider {
    static let chart = Chart(title: "Books read this year", metric: 24, symbol: "book")
    static let star = Chart(title: "Average rating", metric: 3.876543, symbol: "star")
    static var previews: some View {
        VStack {
            ChartView(chart: chart)
            ChartView(chart: star)
        }
    }
}
