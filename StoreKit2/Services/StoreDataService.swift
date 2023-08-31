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

protocol StoreKitManageable {
    // TODO: Update with new methods
    func retrieveProducts() async
    func purchase(_ product: Product) async
    func verifyPurchase<T>(_ verificationResult: VerificationResult<T>) throws -> T
    func transactionStatusStream() -> Task<Void, Error>
}

class StoreDataService: StoreKitManageable, ObservableObject {
    /// Consumables, Non-Consumables, Non-Renewables
    @Published private(set) var products: [Product] = []
    
    /// Auto-Renewables
    @Published private(set) var subscriptions: [Product] = []
    
    @Published private(set) var purchasedNonConsumables: [Product] = []
    @Published private(set) var purchasedConsumables: [Product] = []
    @Published private(set) var purchasedNonRenewables: [Product] = []
    @Published private(set) var purchasedAutoRenewables: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    @Published var transactionCompletionStatus: Bool = false
    
    private let productsIds = [
        "nonconsumable.lifetime",
        "consumable.week",
        "subscription.yearly",
        "nonrenewable.year"
    ]
    private(set) var purchaseStatus: PurchaseStatus = .unknown
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
            
            var newProducts: [Product] = []
            var newSubscriptions: [Product] = []
            
            for product in storeProducts {
                switch product.type {
                case .autoRenewable:
                    newSubscriptions.append(product)
                default:
                    // All other cases get applied to same product array.
                    newProducts.append(product)
                }
            }
            
            // Sort by price and update store
            products = sortByPrice(newProducts)
            subscriptions = sortByPrice(newSubscriptions)
            
            for product in self.products {
                print("Product:: \(product.displayName) in \(product.displayPrice)")
            }
            
            for subcription in self.subscriptions {
                print("Subscription:: \(subcription.displayName) in \(subcription.displayPrice)")
            }
        } catch {
            // Couldn't get products from App Store
            print(error)
        }
    }
    
    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
    
    /// Set purchased products
    @MainActor
    func retrievePurchasedProducts() async {
        var purchasedNonConsumables: [Product] = []
        var purchasedConsumables: [Product] = []
        var purchasedNonRenewables: [Product] = []
        var purchasedAutoRenewables: [Product] = []
        
        // Iterate though the user's purchased products
        for await verificationResult in Transaction.currentEntitlements {
            do {
                // Verify transaction
                let transaction = try verifyPurchase(verificationResult)
                
                guard let product = products.first(where: { $0.id == transaction.productID }) else {
                    // Transaction product is not in our list of products offered.
                    return
                }
                                
                // Check the product type and assign to correct array.
                switch product.type {
                case .nonConsumable:
                    purchasedNonConsumables.append(product)
                case .consumable:
                    purchasedConsumables.append(product)
                case .nonRenewable:
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
        self.purchasedConsumables = purchasedConsumables
        self.purchasedNonRenewables = purchasedNonRenewables
        self.purchasedAutoRenewables = purchasedAutoRenewables
        
        // From Apple on Subscription group statuses:
        /*
            Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
            is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
            group, so products in the subscriptions array all belong to the same group. The statuses that
            `product.subscription.status` returns apply to the entire subscription group.
         */
        subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
    }
    
    /// Make a purchase
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("Purchase successful, verify it")
                do {
                    let verificationResult = try verifyPurchase(verification)
                    purchaseStatus = .success(verificationResult.productID)
                    
                    await verificationResult.finish()
                    transactionCompletionStatus = true
                } catch {
                    purchaseStatus = .failed(error)
                    transactionCompletionStatus = false
                }
            case .pending:
                print("Transaction is pending for user action related to the account")
                purchaseStatus = .pending
                transactionCompletionStatus = false
            case .userCancelled:
                print("User cancelled the transaction")
                purchaseStatus = .cancelled
                transactionCompletionStatus = false
            default:
                print("Unknown error occured")
                purchaseStatus = .failed(StoreKitError.unknownError)
                transactionCompletionStatus = false
            }
        } catch {
            print(error)
            purchaseStatus = .failed(error)
            transactionCompletionStatus = false
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
    

    func transactionStatusStream() -> Task<Void, Error> {
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
}
