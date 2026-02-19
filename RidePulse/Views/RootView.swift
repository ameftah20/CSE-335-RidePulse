//
//  RootView.swift
//  RidePulseApp
//
//  Created by Ahmed Saniad Meftah on 2/14/26.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            Text("Plan")
                .tabItem { Label("Plan", systemImage: "map.fill") }

            Text("Wallet")
                .tabItem { Label("Wallet", systemImage: "wallet.pass.fill") }

            Text("More")
                .tabItem { Label("More", systemImage: "gearshape.fill") }
        }
    }
}
