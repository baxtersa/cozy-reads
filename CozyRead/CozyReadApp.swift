//
//  CozyReadApp.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/1/23.
//

import SwiftUI

struct ProfileColorKey : EnvironmentKey {
    static var defaultValue: Color = Color("AccentColor")
}

extension EnvironmentValues {
  public var profileColor: Color {
    get { self[ProfileColorKey.self] }
    set { self[ProfileColorKey.self] = newValue }
  }
}

extension View {
    func profileColor(_ value: Color) -> some View {
        environment(\.profileColor, value)
    }
}

struct ProfileKey : EnvironmentKey {
    static var defaultValue: Binding<ProfileEntity?> = .constant(nil)
}

extension EnvironmentValues {
    public var profile: Binding<ProfileEntity?> {
        get { self[ProfileKey.self] }
        set { self[ProfileKey.self] = newValue }
    }
}

@main
struct CozyReadApp: App {
    @Environment(\.scenePhase) var scenePhase

    @State private var profile: ProfileEntity? = nil

    @AppStorage(Onboarding.Constants.onboardingVersion) private var hasSeenOnboardingView = false
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboardingView {
                NavBarView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environment(\.profile, $profile)
//                    .profileColor(profile?.color?.color ?? ProfileColorKey.defaultValue)
                    .transition(.slide)
                    .animation(.easeInOut(duration: 2), value: hasSeenOnboardingView)
            } else {
                Onboarding()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environment(\.profile, $profile)
                    .transition(.slide)
            }
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
