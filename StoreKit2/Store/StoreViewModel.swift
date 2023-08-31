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
    @Published private(set) var products: [Product] = []
    @Published private(set) var subscriptions: [Product] = []
    
    @Published private(set) var purchasedNonConsumables: [Product] = []
    @Published private(set) var purchasedConsumables: [Product] = []
    @Published private(set) var purchasedNonRenewables: [Product] = []
    @Published private(set) var purchasedAutoRenewables: [Product] = []
    
    private let storeDataService = StoreDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.addSubscribers()
    }
    
    // I am not sure if there is a better way to do this.
    func addSubscribers() {
        storeDataService.$products
            .sink { (products) in
                self.products = products
            }
            .store(in: &cancellables)
        
        storeDataService.$subscriptions
            .sink { (subscriptions) in
                self.subscriptions = subscriptions
            }
            .store(in: &cancellables)
        
        storeDataService.$purchasedNonConsumables
            .sink { (purchasedNonConsumables) in
                self.purchasedNonConsumables = purchasedNonConsumables
            }
            .store(in: &cancellables)
        
        storeDataService.$purchasedConsumables
            .sink { (purchasedConsumables) in
                self.purchasedConsumables = purchasedConsumables
            }
            .store(in: &cancellables)
        
        storeDataService.$purchasedNonRenewables
            .sink { (purchasedNonRewables) in
                self.purchasedNonRenewables = purchasedNonRewables
            }
            .store(in: &cancellables)
        
        storeDataService.$purchasedAutoRenewables
            .sink { (purchasedAutoRenewables) in
                self.purchasedAutoRenewables = purchasedAutoRenewables
            }
            .store(in: &cancellables)
    }
    
    func purchase(product: Product) {
        Task {
            await storeDataService.purchase(product)
        }
    }
    
    func isPurchased(_ product: Product) -> Bool {
        print("verifing purchase for \(product.id)")
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
