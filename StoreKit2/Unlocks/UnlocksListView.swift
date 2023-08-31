//
//  MoviesView.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI

struct UnlocksListView: View {
    @State var vm: UnlocksViewModel
    @EnvironmentObject var store: StoreViewModel
    
    @State var proFeature1: String = ""
    @State var disableProFeature1: Bool = false
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
