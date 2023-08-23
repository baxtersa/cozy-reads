//
//  MonthlyGoalsView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/2/23.
//

import Foundation
import SwiftUI

struct MonthProgressBar : View {
    let month: String
    let progress: Float

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 5)
                            .opacity(0.3)
                            .foregroundColor(.accentColor)
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.accentColor)
                            .frame(height: geometry.size.height * CGFloat(min(1.0, progress)))
                    }
                    if progress > 1.0 {
                        Image(systemName: "chevron.up")
                            .padding(.top, 5)
                            .foregroundColor(.white)
                            .bold()
                    }
                }
            }
            .frame(minWidth:60)
            Text(month)
                .rotationEffect(.degrees(0))
        }
        .id({ () -> String? in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            guard let dateFromMonth = dateFormatter.date(from: month) else { return nil }
            let abbrev = dateFormatter.string(from: dateFromMonth)
            let currentAbbrev = dateFormatter.string(from: Date.now)
            
            if abbrev == currentAbbrev {
                return "currentMonth"
            } else {
                return nil
            }
        }())
    }
}

struct MonthlyGoalsView : View {
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    
    let yearlyTarget: Int

    private var monthlyAverage: Int {
        yearlyTarget / 12
    }
    private func monthlyProgress(_ booksRead: Int) -> Float {
        Float(booksRead) / Float(monthlyAverage)
    }

    let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollView in
                HStack {
                    let booksMissingCompletion = books.filter { (book: BookCSVData) in
                        guard case let .year(num) = book.year else { return false }
                        return num == currentYear && book.dateCompleted == nil
                    }.count
                    MonthProgressBar(month: "Prev", progress: monthlyProgress(booksMissingCompletion))
                    ForEach(Calendar.current.shortStandaloneMonthSymbols, id: \.self) { month in
                        let booksCompleted = books.filter { (book: BookCSVData) in
                            guard let completed = book.dateCompleted else { return false }
                            let components = Calendar.current.dateComponents([.month, .year], from: completed)
                            guard let monthCompleted = components.month,
                                  let year = components.year,
                                  year == currentYear else { return false }
                            
                            return month == Calendar.current.shortStandaloneMonthSymbols[monthCompleted - 1]
                        }.count
                        MonthProgressBar(month: month, progress: monthlyProgress(booksCompleted))
                    }
                }
                .onAppear {
                    scrollView.scrollTo("currentMonth")
                }
            }
        }
//        .fadeOutSides(fadeLength:20)
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground)))
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .padding(.horizontal)
        .frame(height: 200)
    }
}

struct MonthlyGoalsView_Previews : PreviewProvider {
    static var previews: some View {
        MonthlyGoalsView(yearlyTarget: 50)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
