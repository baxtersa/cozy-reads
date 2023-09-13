//
//  NavBarView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/1/23.
//

import Foundation
import SwiftUI

struct Header : View {
    @Environment(\.profileColor) private var profileColor

    @AppStorage(Onboarding.Constants.onboardingVersion) private var hasSeenOnboarding = false

    var body: some View {
        HStack {
            Image(systemName: "book.fill")
                .font(.system(.largeTitle))
            Text("CozyReads")
                .font(.system(.largeTitle))
            Spacer()
            Button {
                withAnimation {
                    hasSeenOnboarding.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 3)
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(y: 5)
                        .mask {
                            Circle()
                        }
                }
                .frame(width: 30)
            }
            .scaledToFit()
        }
        .padding([.horizontal, .top])
        .foregroundColor(profileColor)
    }
}

struct NavBarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profile) private var envProfile

    @State private var profileColor = ProfileColorKey.defaultValue
    
    @AppStorage(Onboarding.Constants.defaultProfile) private var defaultProfile = ""

    @FetchRequest(sortDescriptors: []) private var profiles: FetchedResults<ProfileEntity>
    
    var body: some View {
        VStack {
            Header()

            TabView {
                DashboardView()
                    .tabItem{
                        Label("Overview", systemImage: "square.grid.2x2")
                    }
                ShelvesView()
                    .tabItem{
                        Label("Shelves", systemImage: "chart.line.uptrend.xyaxis")
                    }
//                GoalsView()
//                    .tabItem{
//                        Label("Goals", systemImage: "chart.line.uptrend.xyaxis")
//                    }
                DataView()
                    .tabItem{
                        Label("Books", systemImage: "books.vertical")
                    }
            }
        }
        .onAppear {
            print("Navbar appeared")
            envProfile.wrappedValue = profiles.first(where: { $0.uuid.uuidString == defaultProfile })
            if let profile = envProfile.wrappedValue,
               let color = profile.color?.color {
                profileColor = color
//                profile.color = color
            }
        }
        .onChange(of: envProfile.wrappedValue) { _ in () }
        .profileColor(profileColor)
        .tint(profileColor)
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environment(\.profileColor, .red)
    }
}
