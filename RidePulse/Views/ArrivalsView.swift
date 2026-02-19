//
//  ArrivalsView.swift
//  RidePulseApp
//
//  Created by Ahmed Saniad Meftah on 2/14/26.
//

import SwiftUI

struct ArrivalsView: View {

    let stopName: String

    var body: some View {
        VStack(spacing: 20) {

            Text(stopName)
                .font(.title2)
                .bold()

            ProgressView()
            Text("Loading arrivals...")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Arrivals")
        .padding()
    }
}

#Preview {
    ArrivalsView(stopName: "Demo Stop")
}
