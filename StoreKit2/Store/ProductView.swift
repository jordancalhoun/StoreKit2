//
//  SwiftUIView.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI
import StoreKit


struct ProductView: View {
    @EnvironmentObject private var storeManager: StoreManager
    let vm: ProductViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.pink, .purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(vm.product.displayName)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.semibold)
                        .padding([.leading, .top])
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                    
                    Text(vm.product.description)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.regular)
                        .padding(.leading)
                        .padding(.top, 5)
                        .foregroundStyle(.regularMaterial)
                        .fontDesign(.rounded)
                }.padding(.bottom)
                
                Spacer()
                
                Button {
                    vm.purchase()
                } label: {
                    Text(vm.product.displayPrice)
                        .fontWeight(.bold)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                }
                .tint(.teal)
                .buttonStyle(.borderedProminent)
                .padding()
                .font(.title3)
                
                
            }
        }
    }
}


#Preview {
//    ProductListView()
//        .environmentObject(StoreManager())
    @State var vm: ProductViewModel?
    
    ProductView(vm: vm ?? ProductViewModel(storeManager: StoreManager(), product: StoreManager().products.first!))
        .task {
            let store = StoreManager()
            await store.retrieveProducts()
            let product = store.products.first!
            vm = ProductViewModel(storeManager: store, product: product)
        }
}
