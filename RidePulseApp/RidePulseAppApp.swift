//
//  RidePulseAppApp.swift
//  RidePulseApp

//                 AUTHOR

//  Created by Ahmed Saniad Meftah on 2/14/26.
//

import SwiftUI
import SwiftData

@main
struct RidePulseAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [FavoriteStop.self, RideCheckIn.self])
    }
}
