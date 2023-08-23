//
//  ShelvesView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/7/23.
//

import Foundation
import Charts
import SwiftUI
//import SwiftUICharts

fileprivate enum Category : String, CaseIterable {
    case author
//    case series
    case genre
    case year
}

struct AuthorGraphs : View {
    let books: [String:[BookCSVData]]

    var body: some View {
        VStack {
            
        }
    }
}

struct DragMarker : View {
    @State private var isDragging: Bool = false
    @State private var dragPosition: CGPoint = .zero

    var body: some View {
        VStack {
            if isDragging {
                GeometryReader { geometry in
                    Text("26")
                        .position(x: dragPosition.x)
                    
                    Path { path in
                        path.move(to: CGPoint(x: dragPosition.x, y: 0))
                        path.addLine(to: CGPoint(x: dragPosition.x, y: geometry.size.height))
                    }
                    .stroke(lineWidth: 1)
                    .frame(width: 1)
                    .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0).onChanged { value in
            isDragging = true
            dragPosition = value.location
        }.onEnded { _ in
            isDragging = false
        })
    }
}

struct GenreGraphs : View {
    let books: [Genre:[BookCSVData]]

    var completed: [Genre:[BookCSVData]] {
        books.mapValues{ $0.filter{ $0.year == selectedYear } }
    }

    @State private var selectedYear: Year = .year(Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023)

    var body: some View {
        let completed = completed.sorted(by: { $0.key < $1.key }).filter{ !$1.isEmpty }
        let data = completed.flatMap{ genre, books in
            [genre:Double(books.count)]
        }

        VStack {
            let years = Array(Set(books.flatMap{ $1.map{ $0.year } }.filter{
                if case .year = $0 {
                    return true
                } else {
                    return false
                }
            })).sorted()
            Picker("Year", selection: $selectedYear) {
                ForEach(Array(years)) { year in
                    Text(year.description)
                }
            }
            .pickerStyle(.menu)

            VStack(alignment: .leading) {
                Text("Books Read")
                    .font(.system(.title2))
                    .bold()
                    .padding([.leading, .top])
                
                Chart(data, id: \.key) { genre, count in
                    let xp: PlottableValue = .value("Genre", genre.rawValue)
                    let yp: PlottableValue =  .value("Books Read", count)
                    BarMark(x: xp, y: yp)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel()
                    }
                }
                .chartYAxis(.hidden)
                .padding(.vertical)
            }
            .background {
                RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
            }
            .padding(.horizontal)
            .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
            
            VStack(alignment: .leading) {
                Text("Average Rating")
                    .font(.system(.title2))
                    .bold()
                    .padding()

                Chart(completed, id: \.key) { genre, books in
                    let avg = books.reduce(0, { acc, book in
                        acc + Float(book.rating) / Float(books.count)
                    })
                    let xp: PlottableValue = .value("Genre", genre.rawValue)
                    let yp: PlottableValue =  .value("Rating", avg)
                    PointMark(x: xp, y: yp)
                        .symbolSize(CGFloat(books.count) * 150)
                        .annotation(position: .overlay) {
                            Text(String(format: "%0.1f", avg))
                                .font(.system(.caption))
                                .fixedSize()
                                .foregroundColor(.white)
                                .bold()
                        }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel()
                    }
                }
                .chartYAxis(.hidden)
                .padding(.vertical)
            }
            .background {
                RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
            }
            .padding(.horizontal)
            .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        }
    }
}

struct YearlyGraphs : View {
    let books: [Year:[BookCSVData]]

    var completed: [Year:[BookCSVData]] {
        books.filter { $0.key != .reading && $0.key != .tbr }
    }
    var rate: Int? {
        let data = completed.sorted(by: { $0.key < $1.key }).flatMap{ year, books in
            [year:Double(books.count)]
        }
        
        // Make sure we have enough data to compute a rate of change with
        guard data.count >= 2 else {
            return nil
        }

        let lastTwoYears = data.dropFirst(data.count - 2)
        var rate: Int?
        if let lastYear = lastTwoYears.first,
           let thisYear = lastTwoYears.last,
           lastYear.key != thisYear.key {
            rate = Int((thisYear.value - lastYear.value) / lastYear.value)
        }
        return rate
    }

    var body: some View {
        let completed = books.filter { $0.key != .reading && $0.key != .tbr }.sorted(by: { $0.key < $1.key })
        let data = completed.flatMap{ year, books in
            [year:Double(books.count)]
        }

        VStack {
            VStack(alignment: .leading) {
                Text("Books Read")
                    .font(.system(.title2))
                    .bold()
                    .padding([.leading, .top])
                if let rate = rate {
                    Text(String(format: "%d", rate))
                        .padding(.leading)
                }
                
                ZStack {
                    Chart(data, id: \.key) { year, count in
                        let xp: PlottableValue = .value("Year", year.description)
                        let yp: PlottableValue =  .value("Books Read", count)
                        LineMark(x: xp, y: yp)
                            .interpolationMethod(.catmullRom)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisValueLabel()
                        }
                    }
                    .chartYAxis(.hidden)
                    
                    DragMarker()
                }
                .padding(.vertical)
            }
            .background {
                RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
            }
            .padding(.horizontal)
            .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)

            VStack(alignment: .leading) {
                Text("Average Rating")
                    .font(.system(.title2))
                    .bold()
                    .padding()

                Chart(completed, id: \.key) { year, books in
                    let avg = books.reduce(0, { acc, book in
                        acc + Float(book.rating) / Float(books.count)
                    })
                    let xp: PlottableValue = .value("Year", year.description)
                    let yp: PlottableValue =  .value("Rating", avg)
                    PointMark(x: xp, y: yp)
                        .symbolSize(CGFloat(books.count) * 150)
                        .annotation(position: .overlay) {
                            Text(String(format: "%0.1f", avg))
                                .font(.system(.caption))
                                .fixedSize()
                                .foregroundColor(.white)
                                .bold()
                        }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel()
                    }
                }
                .chartYAxis(.hidden)
                .padding(.vertical)
            }
            .background {
                RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
            }
            .padding(.horizontal)
            .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        }

// TODO: This is for SwiftUICharts 2.0.0-beta.8
//        GeometryReader { geometry in
//            VStack(alignment: .leading) {
//                Text("Books Read")
//                    .font(.system(.title))
//                    .bold()
//                    .padding()
//
//                AxisLabels {
//                    ChartGrid {
//                        LineChart()
//                            .showChartMarks(true)
//                            .data(data.map{$0.value})
//                            .chartStyle(ChartStyle(backgroundColor: .white, foregroundColor: ColorGradient(.blue, .purple)))
//                            .padding()
//                    }
//                    .setNumberOfHorizontalLines(0)
//                    .setNumberOfVerticalLines(0)
//                }
//                .setAxisXLabels(data.map{$0.key.description})
//                .setColor(.gray)
//                .setFont(.system(.caption2))
//            }
//            .background {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(.white)
//                    .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
//            }
//            .padding()
//            .padding(.horizontal)
//            .frame(width: geometry.size.width, height: 200)
//        }
    }
}

struct ShelvesView : View {
    @FetchRequest(fetchRequest: BookCSVData.getFetchRequest) var books: FetchedResults<BookCSVData>
    
    @State private var categoryFilter: Category = .genre
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Shelves")
                .font(.system(.title))
                .padding(.leading, 10)
            Picker("Filter by", selection: $categoryFilter) {
                ForEach(Category.allCases, id: \.self) { filter in
                    Text(filter.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            ScrollView {
                switch categoryFilter {
                case .author:
                    let dict = Dictionary(grouping: books, by: {
                        $0.author
                    })
                    AuthorGraphs(books: dict)
//                case .series:
//                    let dict = Dictionary(grouping: books, by: {
//                        $0.series
//                    })
//                    EmptyView()
                case .genre:
                    let dict = Dictionary(grouping: books, by: {
                        $0.genre
                    })
                    GenreGraphs(books: dict)
                case .year:
                    let dict = Dictionary(grouping: books, by: {
                        $0.year
                    })
                    YearlyGraphs(books: dict)
                }
            }
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct ShelvesView_Previews : PreviewProvider {
    static var previews: some View {
        ShelvesView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
