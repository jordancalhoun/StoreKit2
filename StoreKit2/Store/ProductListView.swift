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
            List {
                Text("Products")
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding()
                ForEach(vm.products, id: \.self) { product in
                    ProductView(product: product)
                        .listRowSeparator(.hidden)
                }
                
                Text("Subscriptions")
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding()
                ForEach(vm.subscriptions, id: \.self) { subscription in
                    ProductView(product: subscription)
                        .listRowSeparator(.hidden)
                }
                
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
