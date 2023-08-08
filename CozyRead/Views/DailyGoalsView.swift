//
//  DailyGoalsView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

private struct CheckCircle : View {
    @Environment(\.managedObjectContext) var viewContext
    
    @State var entry: ReadingTrackerEntity?
    let date: Date
    
    var body: some View {
        ZStack {
            if entry != nil {
                Circle()
                    .inset(by: 2.5)
                    .stroke(style: StrokeStyle(lineWidth: 5))
                    .foregroundColor(.clear)
                Circle()
                    .fill(.green)
                    .transition(.scale)
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            } else {
                Circle()
                    .inset(by: 2.5)
                    .stroke(style: StrokeStyle(lineWidth: 5))
                    .foregroundColor(.green)
                    .opacity(0.3)
                Image(systemName: "checkmark")
                    .foregroundColor(.clear)
                    .fontWeight(.bold)
            }
        }
        .onTapGesture {
            onDayClicked()
        }
        .animation(.linear(duration: 0.1), value: entry)
    }
    
    private func onDayClicked() {
        if let entry = entry {
            viewContext.delete(entry)
            self.entry = nil
        } else {
            let newEntry = ReadingTrackerEntity(context: viewContext)
            newEntry.date = date
            self.entry = newEntry
        }
        
        PersistenceController.shared.save()
    }
}

struct DailyGoalsView : View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var daysRead: FetchedResults<ReadingTrackerEntity>

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Spacer()
                    let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: Calendar.current.startOfDay(for: .now)) ?? .now
                    let lastFiveDays = daysRead.filter { entry in
                        if let date = entry.date {
                            return date > fiveDaysAgo
                        } else {
                            return false
                        }
                    }
                ForEach(0..<5) { days in
                    let date = Calendar.current.date(byAdding: .day, value: days, to:   fiveDaysAgo)
                    let entry = lastFiveDays.first { entry in
                        entry.date == date
                    }
                    CheckCircle(entry: entry, date: date!)
                }
                Spacer()
            }
            let days = daysInARow
            let daysText = days == 1 ? "day" : "days"
            Text("read \(daysInARow) \(daysText) in a row")
                .padding(.top)
                .italic()
        }
        .scaledToFit()
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(.white)
        )
        .padding(.horizontal)
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }

    private var daysInARow: Int {
        daysRead.compactMap { entry in
            entry.date
        }.enumerated().prefix(while: { (offset, date) in
            guard let checkAgainst = Calendar.current.date(byAdding: .day, value: -1 * offset, to: Calendar.current.startOfDay(for: .now)) else {
                return false
            }
            
            return date == checkAgainst
        }).count
    }
}

struct DailyGoalsView_Previews : PreviewProvider {
    static var previews: some View {
        DailyGoalsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
