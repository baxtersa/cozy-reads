//
//  CreateProfileView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/28/23.
//

import Foundation
import SwiftUI

struct CreateProfileView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.profile) private var profile
    @Environment(\.profileColor) private var profileColor

    @AppStorage(Onboarding.Constants.defaultProfile) private var defaultProfile = ""

    let focusProfileName: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Please create a profile")
            Button {
                let profile = ProfileEntity(context: viewContext)
                profile.uuid = UUID()
                profile.name = "Default"
                
                focusProfileName.wrappedValue = true
                defaultProfile = profile.uuid.uuidString
                
                PersistenceController.shared.save()
            } label: {
                Label("Add", systemImage: "plus.circle")
                    .font(.title)
            }
            .buttonStyle(.bordered)
            Spacer()

            Text("Check out the shop to unlock multiple profiles!")
            
            NavigationLink {
                StoreView()
            } label: {
                Label("Shop", systemImage: "cart")
                    .font(.system(.title))
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(profile.wrappedValue?.color?.color ?? profileColor)
        .foregroundColor(.white)
    }
}

struct CreateProfileView_Previews : PreviewProvider {
    @FocusState static private var focus: Bool
    static var previews: some View {
        NavigationStack {
            CreateProfileView(focusProfileName: $focus)
        }
    }
}
