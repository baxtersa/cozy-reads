//
//  YearlyGoalsView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct CreateYearlyGoal : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profileColor) private var profileColor
    @Environment(\.profile) private var profile
    
    @State private var target: String = ""
    
    let year: Int
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(profileColor, lineWidth: 30)
                    .opacity(0.3)
                TextField("Target", text: $target)
                    .keyboardType(.numberPad)
                    .onSubmit {
                        guard let target = Int(target) else { return }
                        let goal = YearlyGoalEntity(context: viewContext)
                        goal.setYear(year: year)
                        goal.goal = target
                        goal.profile = profile.wrappedValue
                        
                        PersistenceController.shared.save()
                    }
                    .frame(maxWidth: 100)
                    .multilineTextAlignment(.center)
            }
            .frame(maxHeight: 200)
            Text("Set a reading goal for this year")
                .frame(maxWidth: 200)
                .italic()
                .multilineTextAlignment(.center)
                .padding(20)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 30)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground)))
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .padding(.horizontal)
    }
}

struct YearlyGoalsView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profileColor) private var profileColor
    @Environment(\.profile) private var profile

    @State private var goal: String = ""
    @State private var showSheet: Bool = false

    @ObservedObject var target: YearlyGoalEntity
    let current: Int

    private var percentage: Float {
        return Float(current) / Float(target.goal)
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
                    Text("\(current)/\(target.goal) books read")
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
                    VStack {
                        HStack {
                            Text("Target")
                            Spacer()
                            TextField("Target", text: $goal)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        Button {
                            guard let goal = Int(goal) else { return }
                            print("Goal")
                            target.goal = goal
                            PersistenceController.shared.save()

                            showSheet.toggle()
                        } label: {
                            Text("Save")
                        }
                    }
                }
            }
        }
    }
}

struct YearlyGoalsView_Previews : PreviewProvider {
    static let target: YearlyGoalEntity = {
        let target = YearlyGoalEntity(context: PersistenceController.preview.container.viewContext)
        target.setYear(year: 2023)
        target.goal = 3
        
        return target
    }()

    static var previews: some View {
        VStack {
            CreateYearlyGoal(year: 2023)
            YearlyGoalsView(target: target, current: 1)
        }
    }
}
