//
//  StoreManager.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import Foundation
import StoreKit
import Observation

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

protocol StoreKitManageable {
    func retrieveProducts() async
    func purchase(_ product: Product) async
    func verifyPurchase<T>(_ verificationResult: VerificationResult<T>) throws -> T
    func transactionStatusStream() -> Task<Void, Error>
}

@Observable
class StoreManager: StoreKitManageable {
    private(set) var products = [Product]()
    var transactionCompletionStatus: Bool = false
    
    private let productsIds = ["noncomsumable.pro", "consumable.week", "subscription.yearly"]
    private(set) var purchaseStatus: PurchaseStatus = .unknown
    private(set) var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = transactionStatusStream()
        Task {
            await retrieveProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    /// Get products from Store
    func retrieveProducts() async {
        do {
            let products = try await Product.products(for: productsIds)
            self.products = products.sorted(by: { $0.price < $1.price })
            
            for product in self.products {
                print("Product:: \(product.displayName) in \(product.displayPrice)")
            }
        } catch {
            print(error)
        }
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
    
    /// Handle Interruptions
    func transactionStatusStream() -> Task<Void, Error> {
        Task.detached(priority: .background) { @MainActor [weak self] in
            do {
                for await result in Transaction.updates {
                    let transaction = try self?.verifyPurchase(result)
                    self?.purchaseStatus = .success(transaction?.productID ?? "Unknown Product ID")
                    self?.transactionCompletionStatus = true
                    await transaction?.finish()
                }
            } catch {
                self?.transactionCompletionStatus = true
                self?.purchaseStatus = .failed(error)
            }
        }
    }
    
    /// Unlocking in-app features
    func inAppEntitlements() async {
        // Return the array of all transactions
        for await result in Transaction.all {
            dump(result.payloadData)
        }
    }
    
    
    
    
    
    
    
    
}
