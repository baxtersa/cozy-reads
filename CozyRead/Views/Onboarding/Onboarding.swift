//
//  Onboarding.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/23/23.
//

import Foundation
import SwiftUI

struct ProfileSelection : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profileColor) var profileColor
    @Environment(\.profile) var envProfile

    @AppStorage(Onboarding.Constants.onboardingVersion) private var hasSeenOnboardingView = false
    @AppStorage(Onboarding.Constants.defaultProfile) private var defaultProfile = ""
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<ProfileEntity>
    @FetchRequest(fetchRequest: BookCSVData.fetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "profile == nil")))
    private var unassignedBooks: FetchedResults<BookCSVData>
 
    @FocusState private var focusProfileName: Bool
    
    @State private var editing: Bool = false
    
    var body: some View {
        VStack {
            if profiles.isEmpty {
                CreateProfileView(focusProfileName: $focusProfileName)
            } else {
                ZStack {
                    Button {
                        editing.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title)
                            .symbolVariant(editing ? .fill : .none)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                    VStack {
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 30) {
                            ForEach(profiles) { profile in
                                ProfileButton(
                                    editing: $editing,
                                    profile: profile
                                )
                                .frame(width: 100, height: 150)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        if !editing && !unassignedBooks.isEmpty {
                            VStack(spacing: 20) {
                                Text("""
⚠️ There are unlinked books that will not appear in any profile
""")
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                                
                                NavigationLink {
                                    if let selectedProfile = envProfile.wrappedValue {
                                        ProfileDataLinkView(profile: selectedProfile)
                                    }
                                } label: {
                                    HStack {
                                        Text("Manage unlinked books")
                                        Image(systemName: "chevron.right")
                                    }
                                    .underline()
                                }
                            }
                            .padding(.vertical)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.black))
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        if editing {
                            Text("Delete profiles...")
                                .font(.title)
                            
                            Button {
                                editing.toggle()
                            } label: {
                                Text("Done")
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button {
                                let profile = ProfileEntity(context: viewContext)
                                profile.uuid = UUID()
                                profile.name = "Default"
                                
                                focusProfileName = true
                                
                                PersistenceController.shared.save()
                            } label: {
                                Label("Add", systemImage: "plus.circle")
                                    .font(.title)
                            }
                            
                            Button {
                                hasSeenOnboardingView.toggle()
                            } label: {
                                let text = envProfile.wrappedValue == nil ?
                                "Select a profile to continue" :
                                "Done"
                                Text(text)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(envProfile.wrappedValue == nil)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .foregroundColor(.white)
        .background(envProfile.wrappedValue?.color?.color ?? profileColor)
        .onAppear {
            envProfile.wrappedValue = profiles.first(where: { $0.uuid.uuidString == defaultProfile })
        }
        .onChange(of: defaultProfile) { value in
            envProfile.wrappedValue = profiles.first{ $0.uuid.uuidString == value }
        }
        .onChange(of: profiles.count) { value in
            if value == 0 {
                editing = false
            } else if value == 1 {
                if let profile = profiles.first {
                    defaultProfile = profile.uuid.uuidString
                }
            }
        }
    }
}

struct Onboarding : View {
    @Environment(\.profileColor) private var profileColor

    var body: some View {
        NavigationStack {
            ProfileSelection()
        }
        .tint(profileColor)
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
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
