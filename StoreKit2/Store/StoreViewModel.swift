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
    @Published var products: [Product] = []
    @Published var purchasedProducts: [Product] = []
    
    private let storeDataService = StoreDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.addSubscribers()
    }
    
    // I am not 100% positive on why this is the way to sync the data to this VM
    // I assume it partially has to do with the fact that we can't just have
    // function that does self.products = store.products.
    // Possibly would never update?
    func addSubscribers() {
        storeDataService.$products
            .sink { (products) in
                self.products = products
            }
            .store(in: &cancellables)
        
        storeDataService.$purchasedProducts
            .sink { (purchasedProducts) in
                self.purchasedProducts = purchasedProducts
            }
            .store(in: &cancellables)
    }
    
    func purchase(product: Product) {
        Task {
            await storeDataService.purchase(product)
        }
    }
}
