//
//  StoreDataService.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import Foundation
import StoreKit

enum StoreKitError: Error {
    case failedVerification
    case unknownError
}

enum PurchaseStatus {
    case success(String)
    case pending
    case cancelled
    case failed(Error)
    case unknown
}

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

class StoreDataService: ObservableObject {
    // Product from the store
    @Published private(set) var nonConsumables: [Product] = []
    @Published private(set) var consumables: [Product] = []
    @Published private(set) var nonRenewables: [Product] = []
    @Published private(set) var autoRenewables: [Product] = []
    
    // Purchased products from the store
    @Published private(set) var purchasedNonConsumables: [Product] = []
    @Published private(set) var purchasedNonRenewables: [Product] = []
    @Published private(set) var purchasedAutoRenewables: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    // Product ID array for getting products from store.
    // Usually stored in a plist or similar.
    private let productsIds = [
        "nonconsumable.lifetime",
        "consumable.week",
        "subscription.yearly",
        "nonrenewable.year"
    ]
    
    
    @Published private(set) var purchaseStatus: PurchaseStatus = .unknown {
        // Used for educational purposes
        didSet {
            print("--------------------")
            print("Purchase Status: \(purchaseStatus)")
            print("--------------------")
        }
    }

    /// Background task that listens for Store updates
    private(set) var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = transactionStatusStream()
        Task {
            await retrieveProducts()
            await retrievePurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    /// Get products from Store
    @MainActor
    func retrieveProducts() async {
        do {
            let storeProducts = try await Product.products(for: productsIds)
            
            var nonConsumables: [Product] = []
            var consumables: [Product] = []
            var nonRenewables: [Product] = []
            var autoRenewables: [Product] = []
            
            for product in storeProducts {
                switch product.type {
                case .nonConsumable:
                    nonConsumables.append(product)
                case .consumable:
                    consumables.append(product)
                case .nonRenewable:
                    nonRenewables.append(product)
                case .autoRenewable:
                    autoRenewables.append(product)
                default:
                    break
                }
            }
            
            // Sort by price and update store
            self.nonConsumables = sortByPrice(nonConsumables)
            self.consumables = sortByPrice(consumables)
            self.nonRenewables = sortByPrice(nonRenewables)
            self.autoRenewables = sortByPrice(autoRenewables)
            
            print("Store products finished loading.")
        } catch {
            // Couldn't get products from App Store
            print("Couldn't load products from the App Store: \(error)")
        }
    }

    /// Get purchased products
    @MainActor
    func retrievePurchasedProducts() async {
        var purchasedNonConsumables: [Product] = []
        var purchasedNonRenewables: [Product] = []
        var purchasedAutoRenewables: [Product] = []
        
        // Iterate though the user's purchased products
        for await verificationResult in Transaction.currentEntitlements {
            do {
                // Verify transaction
                let transaction = try verifyPurchase(verificationResult)
                
                print("Retrieved:: \(transaction.productID)")
                                
                // Check the product type and assign to correct array.
                switch transaction.productType {
                case .nonConsumable:
                    guard let product = nonConsumables.first(where: { $0.id == transaction.productID }) else {
                        // Transaction product is not in our list of products offered.
                        return
                    }
                    purchasedNonConsumables.append(product)
                case .nonRenewable:
                    guard let product = nonRenewables.first(where: { $0.id == transaction.productID }) else {
                        // Transaction product is not in our list of products offered.
                        return
                    }
                    // Note about nonRenewable experation dates from Apple:
                    /*
                     Non-renewing subscriptions have no inherent expiration date, so they're always
                     contained in `Transaction.currentEntitlements` after the user purchases them.
                     This app defines this non-renewing subscription's expiration date to be one year after purchase.
                     If the current date is within one year of the `purchaseDate`, the user is still entitled to this
                     product.
                 */
                    let currentDate = Date()
                    guard let expirationDate = Calendar(identifier: .gregorian).date(
                        byAdding: DateComponents(year: 1),
                        to: transaction.purchaseDate) else {
                        print("Could not determine expiration date.")
                        return
                    }
                    
                    if currentDate < expirationDate {
                        purchasedNonRenewables.append(product)
                    }
                case .autoRenewable:
                    guard let product = autoRenewables.first(where: { $0.id == transaction.productID }) else {
                        // Transaction product is not in our list of products offered.
                        return
                    }
                    purchasedAutoRenewables.append(product)
                default:
                    // Product type is none of the above.
                    break;
                }
            } catch {
                // Transaction is not valid.
                print(error)
            }
        }
        
        // Update store with purchased products
        self.purchasedNonConsumables = purchasedNonConsumables
        self.purchasedNonRenewables = purchasedNonRenewables
        self.purchasedAutoRenewables = purchasedAutoRenewables
        
        // From Apple on Subscription group statuses:
        /*
            Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
            is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
            group, so products in the subscriptions array all belong to the same group. The statuses that
            `product.subscription.status` returns apply to the entire subscription group.
         */
        subscriptionGroupStatus = try? await autoRenewables.first?.subscription?.status.first?.state
    }
    
    /// Make a purchase
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                do {
                    let verificationResult = try verifyPurchase(verification)
                    
                    await self.retrievePurchasedProducts()
                    await verificationResult.finish()
                    
                    purchaseStatus = .success(verificationResult.productID)
                } catch {
                    purchaseStatus = .failed(error)
                }
            case .pending:
                purchaseStatus = .pending
            case .userCancelled:
                purchaseStatus = .cancelled
            default:
                purchaseStatus = .failed(StoreKitError.unknownError)
            }
        } catch {
            purchaseStatus = .failed(error)
        }
    }
    
    /// Verify the purchase
    func verifyPurchase<T>(_ verifcationResult: VerificationResult<T>) throws -> T {
        switch verifcationResult {
        case .unverified(_, let error):
            throw error // Purchase was successful;however, transaction can't be verified, Jailbroken?
        case .verified(let result):
            return result // Successfully verified
        }
    }

    private func transactionStatusStream() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.verifyPurchase(result)
                    
                    await self.retrievePurchasedProducts()
                    
                    await transaction.finish()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
}
