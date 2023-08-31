//
//  BuyButton.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/31/23.
//

import SwiftUI

struct BuyButtonStyle: ButtonStyle {
    let isPurchased: Bool
    
    init(isPurchased: Bool = false) {
        self.isPurchased = isPurchased
    }
    
    func makeBody(configuration: Configuration) -> some View {
        var bgColor: Color = isPurchased ? Color.green : Color.blue
        bgColor = configuration.isPressed ? bgColor.opacity(0.7) : bgColor.opacity(1)
        
        return configuration.label
            .frame(minWidth: 50)
            .padding(10)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

#Preview("Buy")  {
    Button(action: {}, label: {
        Text("Buy")
            .foregroundColor(.white)
            .bold()
    })
    .buttonStyle(BuyButtonStyle(isPurchased: false))
}

#Preview("Purchase") {
    Button(action: {}, label: {
        Image(systemName: "checkmark")
            .foregroundColor(.white)
            .bold()
    })
    .buttonStyle(BuyButtonStyle(isPurchased: true))
}

//#Preview("Buy") {
//    BuyButton(isPurchased: false)
//        .previewDisplayName("Buy")
//}
