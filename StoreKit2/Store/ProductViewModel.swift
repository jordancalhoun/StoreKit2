//
//  StoreViewModel.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import Foundation
import StoreKit

class ProductViewModel {
    let storeManager: StoreManager
    var product: Product
    
    init(storeManager: StoreManager, product: Product) {
        self.storeManager = storeManager
        self.product = product
    }
    
    func purchase() {
        Task {
            await storeManager.purchase(product)
        }
    }
}
