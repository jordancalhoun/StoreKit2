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
                Text("Purchase Pro to access these features.")
                    .onTapGesture {
                        showingStore.toggle()
                    }
                    .sheet(isPresented: $showingStore, content: {
                        ProductListView()
                            .environmentObject(store)
                    })
            }
        }
    }
    
}

#Preview {
    UnlocksListView(vm: UnlocksViewModel())
        .environmentObject(StoreViewModel())
}

extension UnlocksListView {
    private var proFeatures: some View {
        Section {
            Picker("Pro Feature 1", selection: $proFeature1) {
                Text("Option 1").tag("Option 1")
                Text("Option 2").tag("Option 2")

            }
            .disabled(disableProFeature1)
            
            Toggle("Pro Feature 2", isOn: $disableProFeature1)
        } header: {
            Text("Lifetime Pro Features")
        } footer: {
            Text("These features are unlocked when the lifetime Pro is purchased.")
        }
    }
}
