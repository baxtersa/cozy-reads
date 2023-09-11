//
//  ReadingList.swift
//  CozyRead
//
//  Created by Samuel Baxter on 9/6/23.
//

import Foundation
import SwiftUI

private struct Item : View {
    @Environment(\.profileColor) private var profileColor

    let book: BookCSVData

    @State private var expand: Bool = false
    @State private var rating: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(book.title)
                //                            .font(.system(.title3))
                Spacer()
                Image(systemName: "chevron.down")
                    .animation(.easeInOut, value: expand)
                    .rotationEffect(.degrees(expand ? 0 : -90))
            }
            
            HStack {
                if let series = book.series {
                    Text(series)
                        .font(.system(.caption))
                }
                Spacer()
                Text("by \(book.author)")
                    .italic()
            }
            
            if expand {
                VStack {
                    StarRating(rating: $rating)
                        .ratingStyle(SolidRatingStyle(color: profileColor))
                        .fixedSize()
//                        .frame(width: 200)
                    Button {
                        finishRead()
                        
                        expand.toggle()
                    } label: {
                        Label("Finished", systemImage: "checkmark")
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .clipped()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                expand.toggle()
            }
        }
    }
    
    private func finishRead() {
        let currentYear: Int = Calendar.current.dateComponents([.year], from: Date.now).year ?? 2023
        book.setYear(.year(currentYear))

        book.rating = rating
        book.dateCompleted = Date.now

//        XPLevels.shared.finishedBook()

        PersistenceController.shared.save()
    }
}

struct ReadingList : View {
    @Environment(\.profile) private var profile
    @Environment(\.profileColor) private var profileColor
    @Environment(\.colorScheme) private var colorScheme

    @FetchRequest(fetchRequest: BookCSVData.fetchRequest(
        sortDescriptors: [SortDescriptor(\.dateStarted)],
        predicate: NSPredicate(format: "private_year == 'Reading'")
    ))
    private var books: FetchedResults<BookCSVData>

    var body: some View {
        let books = books.filter{ $0.profile == profile.wrappedValue }

        VStack {
            ForEach(books) { book in
                Item(book: book)

                if book != books.last {
                    Divider()
                }
            }
        }
        .padding()
        .background {
            if colorScheme == .light {
                RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
            } else {
                RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemBackground))
            }
        }
        .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
    }
}

struct ReadingList_Previews : PreviewProvider {
    static var previews: some View {
        ReadingList()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
