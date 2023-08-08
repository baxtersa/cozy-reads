//
//  YearlyGoalsView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct YearlyGoalsView : View {
    let target: Int
    let current: Int
    
    private var percentage: Float {
        return Float(current) / Float(target)
    }
    
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .stroke(lineWidth: 30)
                    .opacity(0.3)
                    .foregroundColor(.green)
                Circle()
                    .trim(from: 0, to: CGFloat(percentage))
                    .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.degrees(270))
                    .foregroundColor(.green)
                VStack {
                    Text(String(format: "%.0f %%", percentage*100))
                        .font(.system(.title))
                        .bold()
                    Text("\(current)/\(target) books read")
                        .italic()
                }
            }
            .frame(maxHeight: 200)
            Spacer()
        }
        .padding(.vertical, 30)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white))
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .padding(.horizontal)
    }
}

    struct YearlyGoalsView_Previews : PreviewProvider {
        static var previews: some View {
            YearlyGoalsView(target: 3, current: 1)
        }
    }
