//
//  UnlocksViewModel.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import Foundation
//import Observation
//import StoreKit
//import Combine

class UnlocksViewModel: ObservableObject {
//    private let store: StoreDataService
//    private var cancellables = Set<AnyCancellable>()
    
    private(set) var status: String?
    var transactionStatus: Bool = false
//    @Published var products: [Product] = []

    init() {
//        self.store = store
//        self.addSubscribers()
    }
    

    
//    func purchaseStatus() -> String {
//        switch store.purchaseStatus {
//        case .success(let productId):
//            return ("Successfully purchased: \(productId)")
//        case .pending:
//            return ("Purchase pending")
//        case .cancelled:
//            return ("Purchase cancelled by user")
//        case .failed(let error):
//            return ("Failed purchase with error:: \(error)")
//        case .unknown:
//            return ("Unknown")
//        }
//    }
}
