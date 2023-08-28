//
//  MoviesView.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI

struct UnlocksListView: View {
    @State var presentedProductModal: Bool = false
    @State var vm: UnlocksViewModel
    
    var body: some View {
        VStack {
            List {
                HStack {
                    HStack{
                        Text("Lifetime Membership")
                        Image(systemName: "star.fill")
                    }
                    
                    Spacer()
                    
                    Button {
                        presentedProductModal = true
                    } label: {
                        Image(systemName: "lock.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $presentedProductModal) {
                        ProductListView()
                            .environmentObject(vm.storeManager)
                    }
                }
                .padding([.top, .bottom])
            }
            
            Text("Purchase Status: \(vm.purchaseStatus())")
        }
    }
    
}

#Preview {
    UnlocksListView(vm: UnlocksViewModel(storeManager: StoreManager()))
}
