//
//  ReadTodayView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 9/5/23.
//

import Foundation
import SwiftUI

struct ReadTodayView : View {
    @Environment(\.profile) private var profile
    @Environment(\.profileColor) private var profileColor
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var readToday: FetchedResults<ReadingTrackerEntity>

    @State private var responded: Bool = false

    var body: some View {
        let today = readToday.contains(where: { entity in
            guard let date = entity.date else { return false }
            return date == Calendar.current.startOfDay(for: .now)
        })
        if today || responded {
            EmptyView()
        } else {
            HStack {
                Text("Have you read today?")
                    .italic()
                Spacer()

                Button {
                    let today = ReadingTrackerEntity(context: viewContext)
                    today.date = Calendar.current.startOfDay(for: .now)

                    if let profile = profile.wrappedValue {
                        today.profile = profile
                    }
                    
                    PersistenceController.shared.save()

                    responded.toggle()
                } label: {
                    Text("Yes")
                }
                Button {
                    responded.toggle()
                } label: {
                    Text("No")
                }
            }
            .buttonStyle(.bordered)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground))
            }
            .padding(.horizontal)
            .shadow(color: Color("ShadowColor"), radius: 10, x: 3, y: 5)
        }
    }
}

struct ReadTodayView_Previews : PreviewProvider {
    static var previews: some View {
        let today = ReadingTrackerEntity(context: PersistenceController.preview.container.viewContext)
//        let _ = today.date = Calendar.current.startOfDay(for: .now)
        
        ReadTodayView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
