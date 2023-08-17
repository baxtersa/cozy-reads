//
//  DailyGoalsView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

private struct DayTracker : View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let daysRead: FetchedResults<ReadingTrackerEntity>
    @State private var dates: Set<DateComponents>
    @Binding var displayPicker: Bool
    
    init(daysRead: FetchedResults<ReadingTrackerEntity>, displayPicker: Binding<Bool>) {
        self.daysRead = daysRead
        self._dates = State(initialValue: Set(daysRead.compactMap{ $0.date }.map {
            Calendar.current.dateComponents([.calendar, .era, .day, .month, .year], from: $0)
        }))
        self._displayPicker = displayPicker
    }

    var body: some View {
        MultiDatePicker("Reading Tracker", selection: $dates)
        Divider()
        Button {
            withAnimation {
                let persistedDays = getPersistedDates()
                let daysToAdd = dates.subtracting(persistedDays)
                let daysToRemove = Set(daysRead.filter{ entry in
                    guard let date = entry.date else { return false }
                    return !dates.contains(where: { components in
                        Calendar.current.date(date, matchesComponents: components)
                    })
                })
                for date in daysToAdd {
                    let entry = ReadingTrackerEntity(context: viewContext)
                    entry.date = Calendar.current.date(from: date)
                }
                for entry in daysToRemove {
                    viewContext.delete(entry)
                }
                PersistenceController.shared.save()
                
                displayPicker.toggle()
            }
        } label: {
            Text("Done")
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding([.trailing])
    }
    
    private func getPersistedDates() -> Set<DateComponents> {
        Set(daysRead.compactMap{ $0.date }.map {
            Calendar.current.dateComponents([.day, .month, .year], from: $0)
        })
    }
}

private struct CheckCircle : View {
    @Environment(\.managedObjectContext) var viewContext
    
    @State var entry: ReadingTrackerEntity? = nil
    let date: Date
    
    var body: some View {
        ZStack {
            if entry != nil {
                    GeometryReader { geometry in
                ZStack {
                        Circle()
                            .inset(by: 2.5)
                            .stroke(style: StrokeStyle(lineWidth: 5))
                            .foregroundColor(.clear)
                            .contentShape(Circle())
                        Circle()
                            .fill(Gradient(colors: [.blue, .purple]))
                            .transition(.scale)
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .frame(height: geometry.size.height / 5)
                    }
                }
            } else {
                ZStack {
                    Circle()
                        .inset(by: 2.5)
                        .stroke(Gradient(colors: [.blue, .purple]), style: StrokeStyle(lineWidth: 5))
                        .opacity(0.3)
                        .contentShape(Circle())
                    Image(systemName: "checkmark")
                        .foregroundColor(.clear)
                        .fontWeight(.bold)
                }
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
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var daysRead: FetchedResults<ReadingTrackerEntity>

    @State private var dates: Set<DateComponents> = []
    @State private var displayPicker: Bool = false

    var body: some View {
        VStack {
            if displayPicker {
                DayTracker(daysRead: daysRead, displayPicker: $displayPicker)
            } else {
                VStack {
                    HStack(spacing: 10) {
                        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: Calendar.current.startOfDay(for: .now)) ?? .now
                        let lastFiveDays = daysRead.filter { entry in
                            if let date = entry.date {
                                return date >= fiveDaysAgo
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
                    }
                    .padding(.horizontal)
                    let days = daysInARow
                    let daysText = days == 1 ? "day" : "days"
                    Text("read \(daysInARow) \(daysText) in a row")
                        .padding(.top)
                        .italic()
                }
                .onTapGesture {
                    withAnimation {
                        displayPicker.toggle()
                    }
                }
            }
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
