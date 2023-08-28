//
//  UnlockListItem.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI

struct UnlockListItem: View {
    @Binding var presentedProductModal: Bool
    @EnvironmentObject var vm: UnlocksViewModel
    
    let title: String
    let purchased: Bool
    
    var body: some View {
        HStack {
            HStack{
                Text(title)
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
}



#Preview {
    UnlockListItem(presentedProductModal: .constant(false), title: "Lifetime Access", purchased: false)
        .environmentObject(UnlocksViewModel(storeManager: StoreManager()))
}
