//
//  Reports.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/28/23.
//

import Foundation
import SwiftUI

struct Backgrounds {
    static let images = [
        "books-0",
        "books-1",
        "books-2",
        "books-3",
        "books-4",
        "books-5",
        "books-6"
    ].map{ UIImage(imageLiteralResourceName: $0) }

    static var randomImage: UIImage {
        images.randomElement() ?? UIImage(imageLiteralResourceName: "books-0")
    }
}

private struct BooksRead : View {
    let year: Year
    let count: Int
    
    private let background = Backgrounds.randomImage
    @State private var appear: Bool = false
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                Image(uiImage: background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            }

            VStack {
                VStack {
                    if appear {
                        Text("In \(year.description)")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.largeTitle))
                            .bold()
                            .transition(.slide)
                            .animation(.easeInOut(duration: 2), value: appear)
                        Text("You read \(count) books")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .font(.system(.title))
                            .transition(.asymmetric(insertion: .push(from: .trailing), removal: .move(edge: .leading)))
                            .contentTransition(.opacity)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 150)
                .background {
//                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                        .blendMode(.multiply)
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding(.vertical)
            .padding(.top)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2)) {
                appear.toggle()
            }
        }
    }
}

private struct AverageRating : View {
    let books: [BookCSVData]

    var averageRating: Float {
        books.reduce(0.0, { acc, book in
            acc + Float(book.rating) / Float(books.count)
        })
    }

    var body: some View {
        Text(String(format: "Average Rating: %0.2f stars", averageRating))
    }
}

private struct FavoriteBooks : View {
    @Environment(\.profileColor) private var profileColor

    let year: Year
    let books: [BookCSVData]

    private let background = Backgrounds.randomImage
    
    var body: some View {
        let topThree = books
            .sorted(by: { $0.rating > $1.rating })
            .prefix(3)
        
        ZStack {
            GeometryReader { _ in
                Image(uiImage: background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            }
            
            VStack {
                Text("Favorite books of \(year.description)")
                    .font(.system(.title))
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                    }

                ForEach(topThree) { book in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(book.title)
                                .font(.system(.title2))
                            Text("by \(book.author)")
                                .italic()
                        }
                        Spacer()
                        StarRating(rating: .constant(book.rating))
                            .ratingStyle(SolidRatingStyle(color: profileColor))
                            .fixedSize()
                    }
                    Divider()
                }
            }
            .foregroundColor(.white)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                    .blendMode(.multiply)
            }
            .padding()
        }
    }
}

private struct MostReadAuthor : View {
    let books: [BookCSVData]
    
    var body: some View {
        if let mostRead = books
            .map({ $0.author })
            .reduce([String:Int](), { dict, author in
                dict.merging([author: 1], uniquingKeysWith: +)
            })
                .sorted(by: { $0.value > $1.value })
                .first {
            VStack {
                Text("Most read author: \(mostRead.key)")
                Text("\(mostRead.value) books")
            }
        }
    }
}

private struct DaysRead : View {
    let year: Year
    let daysRead: [ReadingTrackerEntity]
    
    var body: some View {
        if case let .year(num) = year {
            let daysThisYear = daysRead.filter{
                guard let date = $0.date else { return false }
                let components = Calendar.current.dateComponents([.year], from: date)
                return components.year == num
            }
            VStack {
                Text("\(daysThisYear.count) days read this year")
            }
        }
    }
}

private struct YearlyGoal : View {
    @FetchRequest(sortDescriptors: [])
    private var goals: FetchedResults<YearlyGoalEntity>

    let year: Year
    let books: [BookCSVData]

    var body: some View {
        if let thisYear = goals.first(where: { $0.targetYear == year }) {
            VStack {
                let target = thisYear.goal
                let read = books.count
                Text("Goal: \(target) books")
                Text("You read \(read) books in \(year.description)")
                if target > read {
                    Text(String(format: "You reached %0.0f%% of your goal for \(year.description)", 100*Float(read)/Float(target)))
                } else {
                    Text("Congratulations! You hit your reading goal for \(year.description)")
                }
            }
        } else {
            Text("You did not set a goal for \(year.description)")
        }
    }
}

struct ReadingStory : View {
    let year: Year
    let books: [BookCSVData]
    let daysRead: [ReadingTrackerEntity]
    
    var body: some View {
        StoryReel(interval: 5.0) {
            BooksRead(year: year, count: books.count)
            //                        AverageRating(books: books)
            FavoriteBooks(year: year, books: books)
            //                        MostReadAuthor(books: books)
            //                        DaysRead(year: year, daysRead: daysRead)
            //                        YearlyGoal(year: year, books: books)
        }
    }
}

struct AllTimeReport : View {
    let books: [BookCSVData]
    let daysRead: [ReadingTrackerEntity]

    var body: some View {
        VStack {
            Text("You have read \(books.count) books! Keep it going!")
        }
    }
}

enum ReportView : String, CaseIterable, Identifiable {
    case yearly = "Yearly"
    case all_time = "All-Time"
    
    var id: Self { self }
}

struct Reports<Content: View> : View {
    @Environment(\.profile) private var profile
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest)
    private var books: FetchedResults<BookCSVData>
    @FetchRequest(sortDescriptors: [])
    private var daysRead: FetchedResults<ReadingTrackerEntity>
    
    @State private var mode: ReportView = .yearly
    @State private var fullScreen: Bool = false

    let year: Year
    let label: () -> Content

    var body: some View {
        Button {
            fullScreen.toggle()
        } label: {
            label()
        }
        .fullScreenCover(isPresented: $fullScreen) {
            let books = books
                .filter{ $0.profile == profile.wrappedValue }
            
            ZStack {
                ReadingStory(year: year, books: books.filter{ $0.year == year }, daysRead: Array(daysRead))
                //            ScrollView() {
                //                if mode == .yearly {
                //                    VStack(spacing: 20) {
                //                        ForEach(dict, id: \.key) { year, books in
                //                            YearlyReport(year: year, books: books, daysRead: Array(daysRead))
                //                        }
                //                    }
                //                } else {
                //                    AllTimeReport(books: books, daysRead: Array(daysRead))
                //                }
                //            }
                
                //            Picker("Report Mode", selection: $mode) {
                //                ForEach(ReportView.allCases) { mode in
                //                    Text(mode.rawValue)
                //                }
                //            }
                //            .pickerStyle(.segmented)
                //            .padding()
                Button {
                    fullScreen.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(.title3))
                        .bold()
                        .padding()
                        .background {
                            Circle().fill(.ultraThinMaterial)
                                .blendMode(.multiply)
                        }
                }
                .tint(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
    }
}

struct Reports_Previews : PreviewProvider {
    static var previews: some View {
        Reports(year: .year(2023)) {
            Image(systemName: "play")
                .background {
                    Circle()
                }
        }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
