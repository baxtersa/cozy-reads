//
//  XPLevels.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/21/23.
//

import Foundation
import CoreData
import SwiftUI

struct XPLevels {
    private struct Profile {
        let books: FetchedResults<BookCSVData>
        let days: FetchedResults<ReadingTrackerEntity>
        
        var xp: Int {
            var booksReadXP = 0
            var totalDaysXP: Int = 0
            var streakXP: Int = 0
            
            booksReadXP = books.reduce(0, { acc, book in
                if case .year = book.year {
                    return acc + Values.finishedBook
                } else {
                    return acc
                }
            })
            
            totalDaysXP = days.count * Values.dayRead
            
            let orig: [[Date]] = []
            let grouped = days
                .compactMap{$0.date}
                .reduce(into: orig) { acc, date in
                    if var latestGroup: [Date] = acc.last,
                       let latestDate: Date = latestGroup.last,
                       let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: .now)),
                       latestDate == yesterday {
                        latestGroup.append(date)
                    } else {
                        acc.append([date])
                    }
                }
            
            var xp = 0
            for group in grouped {
                switch group.count {
                case let value where value > 30: xp += Values.consecutiveMonth
                case let value where value > 7: xp += Values.consecutiveWeek
                default: ()
                }
            }
            streakXP = xp
            
            //            print("Books: ", booksReadXP)
            //            print("Total Days: ", totalDaysXP)
            //            print("Streak: ", streakXP)
            let total = booksReadXP + totalDaysXP + streakXP
            print("XP: ", total)
            return total
        }

        func addXP(xp: Int) {
//            let entry = XPEntity(context: persistence.container.viewContext)
//            entry.date = .now
//            entry.xp = Int64(xp)
//
//            persistence.save()
//
//            self.xp += xp
        }
    }

    var xp: Int {
        profile.xp
    }
    
    var level: Int {
        Self.level(for: profile.xp)
    }
    
    private var profile: Profile
    
    init(books: FetchedResults<BookCSVData>, days: FetchedResults<ReadingTrackerEntity>) {
        self.profile = Profile(books: books, days: days)
    }
    
    static func xp(for level: Int) -> Int {
        // xp = 50*level^2 - 50*level
        // xp = 50*level(level - 1)
        // 0, 0, 100, 300, 600, 1000, ...
        return Int((pow(Double(level), 2) + Double(level)) / 2.0 * 100 - (Double(level) * 100))
    }
    
    static func level(for xp: Int) -> Int {
        // xp = 50(level^2 - level)
        // 0 = 50level^2 - 50level - xp
        // level = (50 ± sqrt(2500 - 200*xp)) / 100
        Int((50.0 + sqrt(2500.0 + 200 * Double(xp))) / 100.0)
    }
    
    func dayRead() {
        profile.addXP(xp: Values.dayRead)
    }
    func dayReadRemoved() {
        profile.addXP(xp: Values.dayRead)
    }
    
    func finishedBook() {
        profile.addXP(xp: Values.finishedBook)
    }
}

extension XPLevels {
    private struct Values {
        static let dayRead = 10
        static let consecutiveWeek = 100
        static let consecutiveMonth = 1000

        static let finishedBook = 500
    }
}
