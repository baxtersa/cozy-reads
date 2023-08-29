//
//  StoreView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/28/23.
//

import Foundation
import StoreKit
import SwiftUI

struct StoreView : View {
    @EnvironmentObject private var store: Store
    @Environment(\.profileColor) private var profileColor
    
    var body: some View {
        List {
            Section("Developer Tips") {
                Text("Support the app's development\n(does not unlock any functionality)")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .listRowBackground(Rectangle().fill(profileColor))
                    .foregroundColor(.white)

                ForEach(store.tips) { tip in
                    StoreItem(product: tip)
                }
            }
            .listStyle(GroupedListStyle())
            
            Section("Features") {
                Text("Unlock additional functionality")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .listRowBackground(Rectangle().fill(profileColor))
                    .foregroundColor(.white)

                ForEach(store.features) { feature in
                    StoreItem(product: feature)
                }
            }
            .listStyle(GroupedListStyle())
            
            Button("Restore Purchases", action: {
                Task {
                    //This call displays a system prompt that asks users to authenticate with their App Store credentials.
                    //Call this function only in response to an explicit user action, such as tapping a button.
                    try? await AppStore.sync()
                }
            })
            
        }
        .navigationTitle("Shop")
    }
}

struct StoreView_Previews : PreviewProvider {
    @StateObject static var store = Store()

    static var previews: some View {
        StoreView()
            .environmentObject(store)
    }
}
