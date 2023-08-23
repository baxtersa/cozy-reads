//
//  Onboarding.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/23/23.
//

import Foundation
import SwiftUI

struct ResetOnboarding : View {
    @AppStorage(Onboarding.Constants.onboardingVersion) private var hasSeenOnboardingView = false

    var body: some View {
        Button {
            hasSeenOnboardingView = true
        } label: {
            Text("Done")
        }
        .buttonStyle(.borderedProminent)
    }
}

struct Onboarding : View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage(Constants.onboardingVersion) private var hasSeenOnboardingView = false
    @AppStorage(Constants.defaultProfile) private var defaultProfile = ""
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<ProfileEntity>
    
    @FocusState private var focusProfileName: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 30) {
                if profiles.isEmpty {
                    Text("Please create a profile")
                        .foregroundColor(.white)
                } else {
                    ForEach(profiles) { profile in
                        VStack {
                            Button {
                                defaultProfile = profile.uuid.uuidString
                            } label: {
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 5)
                                    Image(systemName: "person")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .offset(y: 15)
                                        .mask {
                                            Circle()
                                        }
                                }
                            }
                            .foregroundColor(.white)
                            
                            let binding = Binding(
                                get: { profile.name },
                                set: { profile.name = $0 }
                            )
                            TextField("Name", text: binding)
                                .font(.system(.title))
                                .bold()
                                .multilineTextAlignment(.center)
                                .focused($focusProfileName)
                        }
                        .frame(width: 100)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .tabViewStyle(.page(indexDisplayMode: .always))
            Spacer()
            if profiles.isEmpty {
                Button {
                    let profile = ProfileEntity(context: viewContext)
                    profile.uuid = UUID()
                    profile.name = "Default"

                    focusProfileName = true

                    print("Added profile")
                    PersistenceController.shared.save()
                } label: {
                    Label("Add", systemImage: "plus.circle")
                        .font(.title)
                }
                .foregroundColor(.white)
            } else {
                ResetOnboarding()
            }
        }
        .background(Color.accentColor)
    }
}

extension Onboarding {
    struct Constants {
        static let onboardingVersion = "onboarding_v1.0.0"
        static let defaultProfile = "default_profile"
    }
}

struct Onboarding_Previews : PreviewProvider {
    static var previews: some View {
        Onboarding()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
