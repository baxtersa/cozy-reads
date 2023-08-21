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
            TabView {
                DashboardView()
                    .tabItem{
                        Label("Overview", systemImage: "square.grid.2x2")
                    }
                ShelvesView()
                    .tabItem{
                        Label("Shelves", systemImage: "books.vertical")
                    }
                GoalsView()
                    .tabItem{
                        Label("Goals", systemImage: "chart.line.uptrend.xyaxis")
                    }
                DataView()
                    .tabItem{
                        Label("Data", systemImage: "cylinder.split.1x2")
                    }
            }
        }
        .background(Color("BackgroundColor"))
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
