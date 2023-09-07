//
//  ReadingProgress.swift
//  CozyRead
//
//  Created by Samuel Baxter on 9/6/23.
//

import Foundation
import SwiftUI

struct YearlyReadingProgress : View {
    @Environment(\.profileColor) private var profileColor

    @State private var showSheet: Bool = false

    @ObservedObject var target: YearlyGoalEntity
    let current: Int

    private var percentage: Float {
        return Float(current) / Float(target.goal)
    }
    
    var body: some View {
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
    }
}

struct YearlyGoalProgress : View {
    @Environment(\.profileColor) private var profileColor
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var target: YearlyGoalEntity
    let current: Int

    private var percentage: CGFloat {
        return CGFloat(current) / CGFloat(target.goal)
    }

    private let lineWidth: CGFloat = 16
    private var inset: CGFloat {
        lineWidth / 2
    }
    
    @State private var editGoal: Bool = false

    var body: some View {
        VStack {
            Text("Books Read")
            ZStack {
                Circle()
                    .inset(by: inset)
                    .stroke(profileColor, lineWidth: lineWidth)
                    .opacity(0.3)
                Circle()
                    .inset(by: inset)
                    .trim(from: 0, to: percentage)
                    .stroke(profileColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.degrees(270))
            }
            .frame(height: 80)
            Label("\(current)/\(target.goal)", systemImage: "book")
        }
        .onTapGesture {
            editGoal.toggle()
        }
        .sheet(isPresented: $editGoal) {
            Form {
                Section("Yearly Target") {
                    Picker("Target", selection: $target.goal) {
                        ForEach(0..<201) { num in
                            Text(String(num))
                        }
                    }

                    Button {
                        editGoal.toggle()
                    } label: {
                        Text("Save")
                    }
                    .tint(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Button(role: .destructive) {
                        viewContext.delete(target)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onDisappear {
                PersistenceController.shared.save()
            }
        }
    }
}

struct YearlyTotal : View {
    @Environment(\.profileColor) private var profileColor
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profile) private var profile

    let read: Int
    let year: Int
    
    private let lineWidth: CGFloat = 16
    private var inset: CGFloat {
        lineWidth / 2
    }

    @State private var setGoal: Bool = false
    @State private var target: Int = 10
    
    var body: some View {
        VStack {
            Text("Books Read")
            ZStack {
                Circle()
                    .inset(by: inset)
                    .fill(.clear)
                Image(systemName: "book.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(height: 80)
            .foregroundColor(profileColor)
            Text("\(read) books")
        }
        .onTapGesture {
            setGoal.toggle()
        }
        .sheet(isPresented: $setGoal) {
            Form {
                Section("Set a goal") {
                    Picker("Target", selection: $target) {
                        ForEach(0..<201) { num in
                            Text(String(num))
                        }
                    }

                    Button {
                        let goal = YearlyGoalEntity(context: viewContext)
                        goal.goal = target
                        goal.profile = profile.wrappedValue
                        goal.setYear(year: year)

                        PersistenceController.shared.save()

                        setGoal.toggle()
                    } label: {
                        Text("Save")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

struct YearlyAverageRating : View {
    @Environment(\.profileColor) private var profileColor

    let books: [BookCSVData]

    private let maxRating: CGFloat = 5.0
    private var average: CGFloat {
        CGFloat(books.map{ Float($0.rating) }
            .reduce(0.0, { acc, rating in
                acc + rating / Float(books.count)
            })) / maxRating
    }

    private let lineWidth: CGFloat = 16
    private var inset: CGFloat {
        lineWidth / 2
    }
    
    var body: some View {
        let average = average

        VStack {
            Text("Average Rating")
            ZStack {
                Circle()
                    .inset(by: inset)
                    .stroke(profileColor, lineWidth: lineWidth)
                    .opacity(0.3)
                Circle()
                    .inset(by: inset)
                    .trim(from: 0, to: average)
                    .stroke(profileColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.degrees(270))
            }
            .frame(height: 80)
            Label(String(format: "%0.2f", average * maxRating), systemImage: "star")
        }
    }
}

struct ReadingProgress : View {
    @Environment(\.profile) private var profile

    @FetchRequest(sortDescriptors: []) private var yearlyGoals: FetchedResults<YearlyGoalEntity>
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>

    let year: Year

    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }.filter{ $0.year == year}
    
        HStack {
            switch year {
            case .year(let num):
                if let target = yearlyGoals.first(where: { $0.targetYear == year }) {
                    YearlyGoalProgress(target: target, current: books.count)
                } else {
                    YearlyTotal(read: books.count, year: num)
                }
                YearlyAverageRating(books: books)
            case .reading:
                EmptyView()
            case .tbr:
                EmptyView()
            }
        }
        .padding(.vertical)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct ReadingProgress_Previews : PreviewProvider {
    static var previews: some View {
        VStack {
            ReadingProgress(year: .year(2022))
            ReadingProgress(year: .year(2023))
            ReadingProgress(year: .tbr)
            ReadingProgress(year: .reading)
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
