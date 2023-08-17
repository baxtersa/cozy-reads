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
                            .foregroundStyle(Gradient(colors: [.blue, .purple]))
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(Gradient(colors: [.blue, .purple]))
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

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollView in
                HStack {
                    let booksMissingCompletion = books.filter { (book: BookCSVData) in
                        guard book.year != .tbr && book.year != .reading else { return false }
                        return book.dateCompleted == nil
                    }.count
                    MonthProgressBar(month: "Prev", progress: monthlyProgress(booksMissingCompletion))
                    ForEach(Calendar.current.shortStandaloneMonthSymbols, id: \.self) { month in
                        let booksCompleted = books.filter { (book: BookCSVData) in
                            guard let completed = book.dateCompleted else { return false }
                            guard let monthCompleted = Calendar.current.dateComponents([.month], from: completed).month else { return false }
                            return month == Calendar.current.shortStandaloneMonthSymbols[monthCompleted]
                        }.count
                        MonthProgressBar(month: month, progress: monthlyProgress(booksCompleted))
                    }
//                    Group {
//                        MonthProgressBar(month: "Jan", progress: monthlyProgress(4))
//                        MonthProgressBar(month: "Feb", progress: monthlyProgress(4))
//                        MonthProgressBar(month: "Mar", progress: monthlyProgress(2))
//                    }
//                    Group {
//                        MonthProgressBar(month: "Apr", progress: monthlyProgress(3))
//                        MonthProgressBar(month: "May", progress: monthlyProgress(5))
//                        MonthProgressBar(month: "Jun", progress: monthlyProgress(2))
//                    }
//                    Group {
//                        MonthProgressBar(month: "Jul", progress: monthlyProgress(3))
//                        MonthProgressBar(month: "Aug", progress: monthlyProgress(0))
//                        MonthProgressBar(month: "Sep", progress: monthlyProgress(0))
//                    }
//                    Group {
//                        MonthProgressBar(month: "Oct", progress: monthlyProgress(0))
//                        MonthProgressBar(month: "Nov", progress: monthlyProgress(0))
//                        MonthProgressBar(month: "Dec", progress: monthlyProgress(0))
//                    }
                }
                .onAppear {
                    scrollView.scrollTo("currentMonth")
                }
            }
        }
//        .fadeOutSides(fadeLength:20)
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(.white))
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        .padding(.horizontal)
        .frame(height: 200)
    }
}

extension View {
    func fadeOutSides(fadeLength:CGFloat=50) -> some View {
        return mask(
            HStack(spacing: 0) {
                
                // Left gradient
                LinearGradient(gradient: Gradient(
                    colors: [Color.black.opacity(0), Color.black]),
                               startPoint: .leading, endPoint: .trailing
                )
                .frame(width: fadeLength)
                
                // Middle
                Rectangle().fill(Color.black)
                
                // Right gradient
                LinearGradient(gradient: Gradient(
                    colors: [Color.black, Color.black.opacity(0)]),
                               startPoint: .leading, endPoint: .trailing
                )
                .frame(width: fadeLength)
            }
        )
    }
}

struct MonthlyGoalsView_Previews : PreviewProvider {
    static var previews: some View {
        MonthlyGoalsView(yearlyTarget: 50)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
