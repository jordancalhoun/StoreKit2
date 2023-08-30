//
//  SwiftUIView.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI
import StoreKit


struct ProductView: View {
    @EnvironmentObject var vm: StoreViewModel
    let product: Product
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.pink, .purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.semibold)
                        .padding([.leading, .top])
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                    
                    Text(product.description)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.regular)
                        .padding(.leading)
                        .padding(.top, 5)
                        .foregroundStyle(.regularMaterial)
                        .fontDesign(.rounded)
                }.padding(.bottom)
                
                Spacer()
                
                Button {
                    vm.purchase(product: product)
                } label: {
                    Text(product.displayPrice)
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
    ProductListView()
        .environmentObject(StoreViewModel())
}
