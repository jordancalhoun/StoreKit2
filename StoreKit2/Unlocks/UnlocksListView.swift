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
            List {
                Text("Store")
                    .onTapGesture {
                        showingStore.toggle()
                    }
                    .sheet(isPresented: $showingStore, content: {
                        ProductListView(showingStore: $showingStore)
                    })
                
                Text("Consumables are not fully implemented.  This implementation is usually dependent on the setup of each app specificially, so it's skipped here.")
                
            }
        }
    }
    
}

#Preview {
    UnlocksListView(vm: UnlocksViewModel())
        .environmentObject(StoreViewModel())
}
