//
//  StoreView.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/28/23.
//

import Foundation
import StoreKit
import SwiftUI

struct BuyButtonStyle: ButtonStyle {
    let isPurchased: Bool

    init(isPurchased: Bool = false) {
        self.isPurchased = isPurchased
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        var bgColor: Color = isPurchased ? Color.green : Color.blue
        bgColor = configuration.isPressed ? bgColor.opacity(0.7) : bgColor.opacity(1)

        return configuration.label
            .frame(width: 50)
            .padding(10)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct StoreView : View {
    @EnvironmentObject var store: Store

    var body: some View {
        List {
            Section("Tips") {
                if let small = store.smallTip {
                    StoreItem(product: small)
                }
                if let medium = store.mediumTip {
                    StoreItem(product: medium)
                }
            }
            .listStyle(GroupedListStyle())
            
            Section("Features") {
//                ForEach(store.nonRenewables) { product in
//                    ListCellView(product: product, purchasingEnabled: store.purchasedSubscriptions.isEmpty)
//                }
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
