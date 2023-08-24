//
//  Onboarding.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/23/23.
//

import Foundation
import SwiftUI

struct ProfileButton : View {
    @Environment(\.managedObjectContext) private var viewContext

    @AppStorage(Onboarding.Constants.onboardingVersion) private var hasSeenOnboardingView = false
    @AppStorage(Onboarding.Constants.defaultProfile) private var defaultProfile = ""

    @Binding var editing: Bool
    @Binding var selectedProfile: ProfileEntity?
    
    let profile: ProfileEntity
    @FocusState var focusProfileName: Bool
    
    @ViewBuilder func makeSelectedBadge() -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
        }
    }

    @ViewBuilder func makeDeleteBadge() -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "minus.circle")
                .font(.title2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
                .font(.title2)
        }
    }
    
    @State private var deleteConfirmation: Bool = false

    var body: some View {
        VStack {
            Button {
                if editing {
                    deleteConfirmation.toggle()
                } else {
                    selectedProfile = profile
                    defaultProfile = profile.uuid.uuidString
                }
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
                    
                    if editing {
                        makeDeleteBadge()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if selectedProfile == profile {
                        makeSelectedBadge()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .confirmationDialog("Delete", isPresented: $deleteConfirmation) {
                Button(role: .destructive) {
                    if defaultProfile == profile.uuid.uuidString {
                        defaultProfile = ""
                    }
                    viewContext.delete(profile)
                    PersistenceController.shared.save()
                } label: {
                    Text("Delete")
                }
                .keyboardShortcut(.defaultAction)

                Button(role: .cancel) {
                    deleteConfirmation.toggle()
                } label: {
                    Text("Cancel")
                }
            } message: {
                Text("""
This will delete your profile and unlink any associated books

You will be able to link books to a new profile after creating one
""")
            }

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
    }
}

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
                VStack {
                    Spacer()
                    Text("Please create a profile")
                    Spacer()
                    Button {
                        let profile = ProfileEntity(context: viewContext)
                        profile.uuid = UUID()
                        profile.name = "Default"
                        
                        focusProfileName = true
                        defaultProfile = profile.uuid.uuidString
                        
                        PersistenceController.shared.save()
                    } label: {
                        Label("Add", systemImage: "plus.circle")
                            .font(.title)
                    }
                }
                .frame(maxWidth: .infinity)
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
                                    selectedProfile: envProfile,
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
