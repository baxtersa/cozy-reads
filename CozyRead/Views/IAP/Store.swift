//
//  Store.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/28/23.
//

import Foundation
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

enum Tips : String, CaseIterable {
    case small = "com.baxtersa.reads.donation"
    case medium = "com.baxtersa.reads.donation.medium"
    case large = "com.baxtersa.reads.donation.large"
}

enum Features : String, CaseIterable {
    case colorThemes = "com.baxtersa.reads.feature.themes"
    case multipleProfiles = "com.baxtersa.reads.feature.profiles"
}

class Store: ObservableObject {
    static private let productIds: [String] = Tips.allCases.map{$0.rawValue} + Features.allCases.map{$0.rawValue}

    @Published private (set) var tips: [Product]
    @Published private (set) var features: [Product]

    @Published private (set) var smallTip: Product? = nil
    @Published private (set) var mediumTip: Product? = nil

    @Published private (set) var purchasedSmallTip: Product? = nil
    @Published private (set) var purchasedMediumTip: Product? = nil
    
    var updateListenerTask: Task<Void, Error>? = nil

    init() {
        //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()

        Task {
            //During store initialization, request products from the App Store.
            await requestProducts()

            //Deliver products that the customer purchases.
            await updateCustomerProductStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    //Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }

    @MainActor
    func requestProducts() async {
        do {
            //Request products from the App Store using the identifiers that the Products.plist file defines.
            let storeProducts = try await Product.products(for: Store.productIds.map{$0.rawValue})

            //Filter the products into categories based on their type.
            for product in storeProducts {
                switch product.id {
                case "com.baxtersa.reads.donation":
                    smallTip = product
                case "com.baxtersa.reads.donation.medium":
                    mediumTip = product
                default:
                    print("Unknown product")
                }
            }
        } catch {
            print("Failed product request from the App Store server: \(error)")
        }
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        //Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            //The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()

            //Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }

    func isPurchased(_ product: Product) async throws -> Bool {
        //Determine whether the user purchases a given product.
        switch Tips(rawValue: product.id) {
        case .small:
            return purchasedSmallTip != nil
        case .medium:
            return purchasedMediumTip != nil
        default:
            return false
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }

    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSmallTip: Product? = nil
        var purchasedMediumTip: Product? = nil
        
        //Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)

                switch Tips(rawValue: transaction.productID) {
                case .small:
                    purchasedSmallTip = smallTip
                case .medium:
                    purchasedMediumTip = mediumTip
                default:
                    break
                }
            } catch {
                print()
            }
        }

        //Update the store information with the purchased products.
        self.purchasedSmallTip = purchasedSmallTip
        self.purchasedMediumTip = purchasedMediumTip
    }
}
