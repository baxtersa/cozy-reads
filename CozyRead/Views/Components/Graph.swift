//
//  Graph.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/30/23.
//

import Charts
import Foundation
import SwiftUI

//struct PieMark<X: Plottable, Y: Plottable>: ChartContent {
//    let x: PlottableValue<X>
//    let y: PlottableValue<Y>
//    
//    var body: some ChartContent {
//        AreaMark(x: x, y: y)
//    }
//}

struct Graph<Data: RandomAccessCollection, ID: Hashable, Content: ChartContent, SubView: View> : View {
    let title: String
    var subtitle: SubView? = nil

    let data: Data
    
    let id: KeyPath<Data.Element, ID>
    @ChartContentBuilder let content: (Data.Element) -> Content
    
    init(title: String, subtitle: SubView?, data: Data, id: KeyPath<Data.Element, ID>, @ChartContentBuilder content: @escaping (Data.Element) -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.data = data
        self.id = id
        self.content = content
    }
    
    init(title: String, data: Data, id: KeyPath<Data.Element, ID>, @ChartContentBuilder content: @escaping (Data.Element) -> Content) where SubView == EmptyView {
        self.title = title
        self.subtitle = nil
        self.data = data
        self.id = id
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(.title2))
                .bold()
                .padding([.leading, .top])
            if let subtitle = subtitle {
                subtitle
                    .padding(.leading)
            }
            
            ZStack {
                Chart(data, id: id) { element in
                    content(element)
                }
                .chartLegend(.hidden)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel()
                    }
                    AxisMarks(values: .stride(by: .month)) { value in
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel()
                    }
                }
            }
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
        }
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct Graph_Previews : PreviewProvider {
    static let data = ["A": 1].map{$0}

    static var previews: some View {
        Graph(title: "Title", data: data, id: \.key) { (key: String, value: Int) in
            let xp: PlottableValue = .value("Year", key)
            let yp: PlottableValue =  .value("Books Read", value)
            BarMark(x: xp, y: yp)
        }
    }
}
