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
    @State var isPurchased: Bool = true
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.indigo, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(radius: 5)
                
            
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
                
                buyButton
                    .buttonStyle(BuyButtonStyle(isPurchased: isPurchased))
                    .padding()
                
                
            }
        }.padding([.top, .bottom], 6)
    }
}


#Preview {
    ProductListView()
        .environmentObject(StoreViewModel())
}


extension ProductView {
    var buyButton: some View {
        Button(action: {
            vm.purchase(product: product)
        }) {
            if isPurchased {
                Text(Image(systemName: "checkmark"))
                    .bold()
                    .foregroundStyle(.white)
            } else {
                if product.subscription != nil {
                    Text("Subscribe")
                        .bold()
                        .foregroundStyle(.white)
                } else {
                    Text(product.displayPrice)
                        .foregroundStyle(.white)
                        .bold()
                }
            }
        }
        .onAppear {
            self.isPurchased = vm.isPurchased(product)
        }
    }

}
