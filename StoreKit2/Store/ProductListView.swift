//
//  ProductListView.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI
import StoreKit

struct ProductListView: View {
    @EnvironmentObject private var storeManager: StoreManager
    
    var body: some View {
        VStack {
            Text("Packages")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()
            
            List(storeManager.products) { product in
                ProductView(vm: ProductViewModel(storeManager: storeManager, product: product))
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .listRowBackground(Color.clear)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    ProductListView()
        .environmentObject(StoreManager())
}
