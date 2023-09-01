//
//  StoreViewModel.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import Foundation
import StoreKit
import Combine


class StoreViewModel: ObservableObject {
    // Product from the store
    @MainActor @Published private(set) var nonConsumables: [Product] = []
    @MainActor @Published private(set) var consumables: [Product] = []
    @MainActor @Published private(set) var nonRenewables: [Product] = []
    @MainActor @Published private(set) var autoRenewables: [Product] = []
    
    @MainActor @Published private(set) var purchasedNonConsumables: [Product] = []
    @MainActor @Published private(set) var purchasedConsumables: [Product] = []
    @MainActor @Published private(set) var purchasedNonRenewables: [Product] = []
    @MainActor @Published private(set) var purchasedAutoRenewables: [Product] = []
    
    private let storeDataService = StoreDataService()
    
    init() {
        self.addSubscribers()
    }
    
    func addSubscribers() {
        Task {
            for await value in storeDataService.$consumables.values {
                await MainActor.run {
                    self.consumables = value
                }
            }
        }
        
        Task {
            for await value in storeDataService.$nonConsumables.values {
                await MainActor.run {
                    self.nonConsumables = value
                }
            }
        }
        
        Task {
            for await value in storeDataService.$nonRenewables.values {
                await MainActor.run {
                    self.nonRenewables = value
                }
            }
        }
         
        Task {
            for await value in storeDataService.$autoRenewables.values {
                await MainActor.run {
                    self.autoRenewables = value
                }
            }
        }
        
        Task {
            for await value in storeDataService.$purchasedConsumables.values {
                await MainActor.run {
                    self.purchasedConsumables = value
                }
            }
        }
        
        Task {
            for await value in storeDataService.$purchasedNonConsumables.values {
                await MainActor.run {
                    self.purchasedNonConsumables = value
                }
            }
        }
            
        Task {
            for await value in storeDataService.$purchasedNonRenewables.values {
                await MainActor.run {
                    self.purchasedNonRenewables = value
                }
            }
        }
            
        Task {
            for await value in storeDataService.$purchasedAutoRenewables.values {
                await MainActor.run {
                    self.purchasedAutoRenewables = value
                }
            }
        }
    }
    
    func purchase(product: Product) async -> Bool {
        return await storeDataService.purchase(product)
    }
    
    @MainActor func isPurchased(_ product: Product) -> Bool {
        switch product.type {
        case .nonConsumable:
            return purchasedNonConsumables.contains(where: { $0.id == product.id })
        case .consumable:
            return purchasedConsumables.contains(where: { $0.id == product.id })
        case .nonRenewable:
            return purchasedNonRenewables.contains(where: { $0.id == product.id })
        case .autoRenewable:
            return purchasedAutoRenewables.contains(where: { $0.id == product.id })
        default:
            return false
        }
    }
}
