//
//  MoviesViewModel.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import Foundation
import Observation

@Observable
class UnlocksViewModel: ObservableObject {
    private(set) var storeManager: StoreManager
    private(set) var status: String?
    var transactionStatus: Bool = false
    
    init(storeManager: StoreManager) {
        self.storeManager = storeManager
    }
    
    func purchaseStatus() -> String {
        switch storeManager.purchaseStatus {
        case .success(let productId):
            return ("Successfully purchased: \(productId)")
        case .pending:
            return ("Purchase pending")
        case .cancelled:
            return ("Purchase cancelled by user")
        case .failed(let error):
            return ("Failed purchase with error:: \(error)")
        case .unknown:
            return ("Unknown")
        }
    }
}
