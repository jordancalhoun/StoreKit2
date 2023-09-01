//
//  StoreViewModel.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import Foundation
import StoreKit

class StoreViewModel: ObservableObject {
    @Published private(set) var nonConsumables: [Product] = []
    @Published private(set) var consumables: [Product] = []
    @Published private(set) var nonRenewables: [Product] = []
    @Published private(set) var autoRenewables: [Product] = []
    
    @Published private(set) var purchasedNonConsumables: [Product] = []
    @Published private(set) var purchasedNonRenewables: [Product] = []
    @Published private(set) var purchasedAutoRenewables: [Product] = []
    
    @Published private(set) var purchaseStatus: PurchaseStatus = .unknown {
        didSet {
            // Alert the user if there is an eror purchasing
            switch purchaseStatus {
            case .failed(let error):
                alertMessage = "There was an error completing your purchase: \(error.localizedDescription)."
                isAlertShowing = true
            default:
                return
            }
        }
    }
    
    @Published var isAlertShowing: Bool = false
    @Published var alertMessage: String = ""
    
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
        
        Task {
            for await value in storeDataService.$purchaseStatus.values {
                await MainActor.run {
                    self.purchaseStatus = value
                }
            }
        }
    }
    
    func purchase(product: Product)  {
        Task {
            await storeDataService.purchase(product)
        }
    }
    
    func isPurchased(_ product: Product) -> Bool {
        switch product.type {
        case .nonConsumable:
            return purchasedNonConsumables.contains(where: { $0.id == product.id })
        case .nonRenewable:
            return purchasedNonRenewables.contains(where: { $0.id == product.id })
        case .autoRenewable:
            return purchasedAutoRenewables.contains(where: { $0.id == product.id })
        default:
            return false
        }
    }
}
