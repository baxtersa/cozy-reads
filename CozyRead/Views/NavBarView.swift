//
//  NavBarView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/1/23.
//

import Foundation
import SwiftUI

struct NavBarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(.largeTitle))
                    .foregroundStyle(Gradient(colors: [.blue, .purple]))
                Text("CozyReads")
                    .font(.system(.largeTitle))
                    .foregroundStyle(Gradient(colors: [.blue, .purple]))
            }
            .padding(.horizontal)
            TabView {
                DashboardView()
                    .tabItem{
                        Label("Dashboard", systemImage: "square.grid.2x2")
                    }
                HistoryView()
                    .tabItem{
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                TBRView()
                    .tabItem {
                        Label("TBR", systemImage: "books.vertical")
                    }
                    .environment(\.managedObjectContext, viewContext)
                GoalsView()
                    .tabItem{
                        Label("Goals", systemImage: "checkmark.square")
                    }
                DataView()
                    .tabItem{
                        Label("Data", systemImage: "cylinder.split.1x2")
                    }
            }
            .background(Color("BackgroundColor"))
        }
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
