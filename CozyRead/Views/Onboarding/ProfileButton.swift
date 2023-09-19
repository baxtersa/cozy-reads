//
//  ProfileButton.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/28/23.
//

import Foundation
import SwiftUI

struct ProfileButton : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profile) private var selectedProfile

    @EnvironmentObject private var store: Store

    @AppStorage(Onboarding.Constants.onboardingVersion) private var hasSeenOnboardingView = false
    @AppStorage(Onboarding.Constants.defaultProfile) private var defaultProfile = ""

    @Binding var editing: Bool
    
    @ObservedObject var profile: ProfileEntity
    @FocusState var focusProfileName: Bool
    
    @ViewBuilder private func makeSelectedBadge() -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
        }
    }

    @ViewBuilder private func makeDeleteBadge() -> some View {
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
    private var colorThemesUnlocked: Bool {
        store.colorThemesAvailable
    }

    var body: some View {
        VStack {
            Button {
//                profile.color = nil
                if editing {
                    deleteConfirmation.toggle()
                } else {
                    selectedProfile.wrappedValue = profile
                    defaultProfile = profile.uuid.uuidString
                }
            } label: {
                ZStack {
                    Circle()
                        .inset(by: 2.5)
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
                    } else if selectedProfile.wrappedValue == profile {
                        makeSelectedBadge()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .scaledToFit()
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

            HStack {
                let binding = Binding(
                    get: { profile.name },
                    set: { profile.name = $0 }
                )
                TextField("Name", text: binding)
                    .font(.system(.title))
                    .bold()
                    .multilineTextAlignment(.center)
                    .focused($focusProfileName)
                    .fixedSize()
                if colorThemesUnlocked {
                    ProfileColorPicker(profile: profile)
                        .frame(width: 50)
                }
            }
        }
    }
}

struct ProfileButton_Previews : PreviewProvider {
    static let profile = {
        let profile = ProfileEntity(context: PersistenceController.preview.container.viewContext)
        profile.uuid = UUID()
        profile.name = "Sam"

        return profile
    }()

    static var previews: some View {
        ProfileButton(editing: .constant(false), profile: profile)
            .environmentObject(Store())
    }
}
