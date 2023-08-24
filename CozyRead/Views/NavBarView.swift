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
    @Environment(\.profileColor) private var profileColor
    @Environment(\.profile) private var envProfile
    
    @AppStorage(Onboarding.Constants.onboardingVersion) private var hasSeenOnboarding = false
    @AppStorage(Onboarding.Constants.defaultProfile) private var defaultProfile = ""

    @FetchRequest(sortDescriptors: []) private var profiles: FetchedResults<ProfileEntity>
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(.largeTitle))
                    .foregroundColor(profileColor)
                Text("CozyReads")
                    .font(.system(.largeTitle))
                    .foregroundColor(profileColor)
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
                    .foregroundColor(profileColor)
                }
                .scaledToFit()
            }
            .padding(.horizontal)

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
                DataViewV2()
                    .tabItem{
                        Label("Data", systemImage: "cylinder.split.1x2")
                    }
            }
        }
        .onAppear {
            print("Navbar appeared")
            envProfile.wrappedValue = profiles.first(where: { $0.uuid.uuidString == defaultProfile })
        }
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
