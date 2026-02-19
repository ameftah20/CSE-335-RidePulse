//
//  HomeView.swift
//  RidePulseApp
//
//  Created by Ahmed Saniad Meftah on 2/14/26.
//

import SwiftUI
import SwiftData
import CoreLocation


struct HomeView: View {
    @State private var selectedStop: StopDTO?

    @StateObject private var loc = LocationManager()
    @StateObject private var vm = HomeViewModel()

    @Query(sort: \FavoriteStop.createdAt, order: .reverse) private var favorites: [FavoriteStop]

  //  @State private var selectedStop: StopDTO?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Nearest")
                            .font(.headline)
                        Text("Based on your location")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Refresh") {
                        Task { await vm.loadStops(userLocation: loc.location?.coordinate) }
                    }
                }
                .padding(.top, 8)

                if vm.isLoading {
                    ProgressView("Loading nearby stops...")
                        .padding(.top, 12)
                } else if let msg = vm.errorMessage {
                    Text(msg).foregroundStyle(.red)
                }

                StopsTableView(stops: vm.stops) { stop in
                    selectedStop = stop
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Favorites")
                        .font(.headline)

                    if favorites.isEmpty {
                        Text("No favorites yet.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(favorites) { fav in
                                    Text(fav.name)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(.thinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal)
            .navigationTitle("RidePulse")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                loc.requestPermission()
            }
            .onChange(of: loc.location) { _, newLoc in
                Task { await vm.loadStops(userLocation: newLoc?.coordinate) }
            }
        }
    }
}
