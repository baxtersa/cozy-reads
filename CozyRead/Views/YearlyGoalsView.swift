//
//  YearlyGoalsView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct YearlyGoalsView : View {
    @Environment(\.profileColor) private var profileColor

    @State private var showSheet: Bool = false
    @State var target: Int
    let current: Int
    
    private var percentage: Float {
        return Float(current) / Float(target)
    }
    
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .stroke(profileColor, lineWidth: 30)
                    .opacity(0.3)
                Circle()
                    .trim(from: 0, to: CGFloat(percentage))
                    .stroke(profileColor, style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.degrees(270))
                VStack {
                    Text(String(format: "%.0f %%", percentage*100))
                        .font(.system(.title))
                        .bold()
                    Text("\(current)/\(target) books read")
                        .italic()
                }
            }
            .onTapGesture {
                showSheet.toggle()
            }
            .frame(maxHeight: 200)
            Spacer()
        }
        .padding(.vertical, 30)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground)))
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .padding(.horizontal)
        .sheet(isPresented: $showSheet) {
            Form {
                Section("Yearly Target") {
                    Picker("Target", selection: $target) {
                        ForEach(0..<100) { offset in
                            Text("\(offset)")
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
        }
    }
}

    struct YearlyGoalsView_Previews : PreviewProvider {
        static var previews: some View {
            YearlyGoalsView(target: 3, current: 1)
        }
    }
