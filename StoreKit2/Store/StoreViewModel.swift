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
    @MainActor @Published private(set) var products: [Product] = []
    @MainActor @Published private(set) var subscriptions: [Product] = []
    
    @MainActor @Published private(set) var purchasedNonConsumables: [Product] = []
    @MainActor @Published private(set) var purchasedConsumables: [Product] = []
    @MainActor @Published private(set) var purchasedNonRenewables: [Product] = []
    @MainActor @Published private(set) var purchasedAutoRenewables: [Product] = []
    
    private let storeDataService = StoreDataService()
//    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.addSubscribers()
    }
    
    func addSubscribers() {
        Task {
            for await value in storeDataService.$products.values {
                await MainActor.run {
                    self.products = value
                }
            }
            
            for await value in storeDataService.$subscriptions.values {
                await MainActor.run {
                    self.subscriptions = value
                }
            }
            
            for await value in storeDataService.$purchasedConsumables.values {
                await MainActor.run {
                    self.purchasedConsumables = value
                }
            }
            
            for await value in storeDataService.$purchasedNonConsumables.values {
                await MainActor.run {
                    self.purchasedNonConsumables = value
                }
            }
            
            for await value in storeDataService.$purchasedNonRenewables.values {
                await MainActor.run {
                    self.purchasedNonRenewables = value
                }
            }
            
            for await value in storeDataService.$purchasedAutoRenewables.values {
                await MainActor.run {
                    self.purchasedAutoRenewables = value
                }
            }
        }
//        storeDataService.$products
//            .sink { (products) in
//                self.products = products
//            }
//            .store(in: &cancellables)
//        
//        storeDataService.$subscriptions
//            .sink { (subscriptions) in
//                self.subscriptions = subscriptions
//            }
//            .store(in: &cancellables)
//        
//        storeDataService.$purchasedNonConsumables
//            .sink { (purchasedNonConsumables) in
//                self.purchasedNonConsumables = purchasedNonConsumables
//            }
//            .store(in: &cancellables)
//        
//        storeDataService.$purchasedConsumables
//            .sink { (purchasedConsumables) in
//                self.purchasedConsumables = purchasedConsumables
//            }
//            .store(in: &cancellables)
//        
//        storeDataService.$purchasedNonRenewables
//            .sink { (purchasedNonRewables) in
//                self.purchasedNonRenewables = purchasedNonRewables
//            }
//            .store(in: &cancellables)
//        
//        storeDataService.$purchasedAutoRenewables
//            .sink { (purchasedAutoRenewables) in
//                self.purchasedAutoRenewables = purchasedAutoRenewables
//            }
//            .store(in: &cancellables)
    }
    
    func purchase(product: Product) {
        Task {
            await storeDataService.purchase(product)
        }
    }
    
    @MainActor func isPurchased(_ product: Product) -> Bool {
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
