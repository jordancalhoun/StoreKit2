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
    @Binding var showingStore: Bool
    
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
                
                Button("Restore Purchases", action: {
                    Task {
                        //This call displays a system prompt that asks users to authenticate with their App Store credentials.
                        //Call this function only in response to an explicit user action, such as tapping a button.
                        try? await AppStore.sync()
                    }
                })
                
            }
            .listStyle(PlainListStyle())
            .listRowBackground(Color.clear)
            .scrollContentBackground(.hidden)

        }
    }
}

#Preview {
    ProductListView(showingStore: .constant(true))
        .environmentObject(StoreViewModel())
}
