//
//  MoviesView.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI

struct MoviesView: View {
    @State var presentedProductModal: Bool = false
    @State var vm: MoviesViewModel
    
    var body: some View {
        VStack {
            Image("movie_poster")
                .resizable()
                .scaledToFit()
                .frame(height: 500)
                .cornerRadius(10)
            
            Button {
                presentedProductModal = true
            } label: {
                Text("Buy Now")
                    .font(.title2)
                    .frame(maxWidth: 240)
                
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .sheet(isPresented: $presentedProductModal) {
                ProductListView()
                    .environmentObject(vm.storeManager)
            }
            
            Text("Purchase Status: \(vm.purchaseStatus())")
        }
    }
    
}

#Preview {
    MoviesView(vm: MoviesViewModel(storeManager: StoreManager()))
}
