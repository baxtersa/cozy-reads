//
//  StoreItem.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/28/23.
//

import Foundation
import StoreKit
import SwiftUI

struct StoreItem : View {
    @EnvironmentObject var store: Store

    @State private var isPurchased: Bool = false
    @State private var errorTitle = ""
    @State private var isShowingError: Bool = false

    let product: Product

    var body: some View {
        HStack {
            productDetail
            Spacer()
            buyButton
                .buttonStyle(BuyButtonStyle(isPurchased: isPurchased))
                .disabled(isPurchased)
        }
    }

    @ViewBuilder
    private var productDetail: some View {
        VStack(spacing: 10) {
            Text(product.displayName)
                .font(.system(.title3))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(product.description)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var buyButton: some View {
        Button(action: {
            Task {
                await buy()
            }
        }) {
            if isPurchased {
                Text(Image(systemName: "checkmark"))
                    .bold()
                    .foregroundColor(.white)
            } else {
                Text(product.displayPrice)
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .onAppear {
            Task {
                isPurchased = (try? await store.isPurchased(product)) ?? false
            }
        }
    }

    func buy() async {
        do {
            if try await store.purchase(product) != nil {
                withAnimation {
                    isPurchased = true
                }
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(product.id): \(error)")
        }
    }
}
