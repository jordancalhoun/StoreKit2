//
//  ProductListView.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI
import StoreKit

struct ProductListView: View {
    @EnvironmentObject var vm: StoreViewModel
    
    var body: some View {
        VStack {
            Text("Packages")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()
            
            List(vm.products) { product in
                ProductView(product: product)
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
        .environmentObject(StoreViewModel())
}
