//
//  CozyReadApp.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/1/23.
//

import SwiftUI

@main
struct CozyReadApp: App {
    @Environment(\.scenePhase) var scenePhase
    @AppStorage(Onboarding.Constants.onboardingVersion) private var hasSeenOnboardingView = false
    @AppStorage(Onboarding.Constants.defaultProfile) private var profile = ""
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboardingView {
                NavBarView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                Onboarding()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
        .onChange(of: profile) { value in
//            persistenceController.container.loadProfile(for: value)
            print("Selected profile: ", value)
        }
    }
}
