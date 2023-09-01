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
                categoryGroup(title: "NonConsumables", products: vm.nonConsumables)
                
                categoryGroup(title: "Consumables", products: vm.consumables)
                
                categoryGroup(title: "NonRenewables", products: vm.nonRenewables)
                
                categoryGroup(title: "AutoRnewables", products: vm.autoRenewables)
                
                restorePurchases
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

extension ProductListView {
    private func categoryGroup(title: String, products: [Product]) -> some View{
        return Group {
            Text(title)
                .font(.title)
                .fontWeight(.heavy)
            
            ForEach(products, id: \.self) { product in
                ProductView(product: product)
                    .listRowSeparator(.hidden)
            }
            .padding(.bottom)
        }
    }
    
    var restorePurchases: some View {
        Button("Restore Purchases", action: {
            Task {
                //This call displays a system prompt that asks users to authenticate with their App Store credentials.
                //Call this function only in response to an explicit user action, such as tapping a button.
                try? await AppStore.sync()
            }
        })
    }
}
