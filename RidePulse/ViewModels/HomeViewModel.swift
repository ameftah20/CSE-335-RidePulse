//
//  HomeViewModel.swift
//  RidePulseApp
//
//  Created by Ahmed Saniad Meftah on 2/14/26.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var stops: [StopDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: TransitAPIProtocol

    init(api: TransitAPIProtocol = MockTransitAPI()) {
        self.api = api
    }

    func loadStops(userLocation: CLLocationCoordinate2D?) async {
        guard let userLocation else { return }
        isLoading = true
        errorMessage = nil
        do {
            stops = try await api.fetchNearbyStops(userLocation: userLocation)
        } catch {
            errorMessage = "Failed to load nearby stops."
        }
        isLoading = false
    }
}
