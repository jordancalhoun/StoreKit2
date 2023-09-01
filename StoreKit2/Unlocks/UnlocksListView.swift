//
//  MoviesView.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI

struct UnlocksListView: View {
    @EnvironmentObject var store: StoreViewModel
    @State var vm: UnlocksViewModel
    @State var showingStore: Bool = false
    
    var body: some View {
        VStack {
            title
            Divider()
            
            VStack(alignment: .leading) {
                about
                todos
            }
            .padding()
            .foregroundStyle(.primary)
            
            Spacer()
            storeButton
        }
    }
    
}

#Preview {
    UnlocksListView(vm: UnlocksViewModel())
        .environmentObject(StoreViewModel())
}

extension UnlocksListView {
    var storeButton: some View {
        Button(action: { showingStore.toggle() }) {
            HStack(alignment: .center) {
                Image(systemName: "bag")
                Text("Store")
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .popover(isPresented: $showingStore, content: {
            ProductListView(showingStore: $showingStore)
        })
    }
    
    var title: some View {
        Group {
            Text("Welcome to StoreKit 2")
                .font(.title)
                .fontWeight(.bold)
            .foregroundStyle(.primary)
            
            Text("with MVVM")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    var todos: some View {
        ForEach(["Store consumables into AppStorage", "Add Promo Code Fields", "Setup Cancelation/Refund buttons"], id: \.self) {
            Text("• \($0)")
        }
    }
    
    var about: some View {
        Text("This app implements the StoreKit 2 API with MVVM Architecture.  Below are a few things that still need to be done:")
            .padding(.bottom)
    }
}
