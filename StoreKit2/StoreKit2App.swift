//
//  StoreKit2App.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI

@main
struct StoreKit2App: App {
    @State var store = StoreViewModel()
    
    var body: some Scene {
        WindowGroup {
            UnlocksListView(vm: UnlocksViewModel())
                .environmentObject(store)
        }
    }
}
