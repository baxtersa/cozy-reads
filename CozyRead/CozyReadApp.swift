//
//  CozyReadApp.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/1/23.
//

import SwiftUI

struct ProfileColorKey : EnvironmentKey {
    static var defaultValue: Color = Color.accentColor
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

    @State private var profileColor = ProfileColorKey.defaultValue
    @State private var profile: ProfileEntity? = nil

    @AppStorage(Onboarding.Constants.onboardingVersion) private var hasSeenOnboardingView = false
    @AppStorage(Onboarding.Constants.defaultProfile) private var profileUUID = ""
    
//    @FetchRequest(sortDescriptors: []) private var allProfiles: FetchedResults<ProfileEntity>
//    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboardingView {
                NavBarView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environment(\.profile, $profile)
                    .profileColor(profileColor)
                    .tint(profileColor)
                    .transition(.slide)
                    .animation(.easeInOut(duration: 2), value: hasSeenOnboardingView)
            } else {
                Onboarding()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environment(\.profile, $profile)
                    .profileColor(profileColor)
                    .tint(profileColor)
                    .transition(.slide)
            }
        }
//        .onChange(of: allProfiles) { _ in
//            print("Fetched profiles")
//        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
        .onChange(of: profileUUID) { value in
            print("Selected profile: ", value)
        }
        .onChange(of: profile) { profile in
            print("Profile Changed: ", profile?.name)
        }
        .onChange(of: profile?.color?.color) { color in
            print("Profile color changed")
            guard let color = color else { return }
            profileColor = color
        }
    }
}
