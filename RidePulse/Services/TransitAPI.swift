//
//  TransitAPI.swift
//  RidePulseApp
//
//  Created by Ahmed Saniad Meftah on 2/14/26.
//

import Foundation
import CoreLocation

protocol TransitAPIProtocol {
    func fetchNearbyStops(userLocation: CLLocationCoordinate2D) async throws -> [StopDTO]
    func fetchArrivals(stopId: String) async throws -> [ArrivalDTO]
}

final class MockTransitAPI: TransitAPIProtocol {
    func fetchNearbyStops(userLocation: CLLocationCoordinate2D) async throws -> [StopDTO] {
        try await Task.sleep(nanoseconds: 350_000_000)
        return [
            StopDTO(id: "50206", name: "Spence Av & Terrace Rd", lat: userLocation.latitude + 0.0012, lon: userLocation.longitude - 0.0010),
            StopDTO(id: "50207", name: "University Dr & Rural Rd", lat: userLocation.latitude - 0.0010, lon: userLocation.longitude + 0.0014),
            StopDTO(id: "50208", name: "Apache Blvd & McClintock", lat: userLocation.latitude + 0.0020, lon: userLocation.longitude + 0.0008)
        ]
    }

    func fetchArrivals(stopId: String) async throws -> [ArrivalDTO] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return [
            ArrivalDTO(id: "\(stopId)-1", routeName: "MARS", destination: "Southern+Evergreen", minutes: 3),
            ArrivalDTO(id: "\(stopId)-2", routeName: "MARS", destination: "Southern+Evergreen", minutes: 11),
            ArrivalDTO(id: "\(stopId)-3", routeName: "MARS", destination: "Southern+Evergreen", minutes: 26),
            ArrivalDTO(id: "\(stopId)-4", routeName: "MARS", destination: "Southern+Evergreen", minutes: 41)
        ]
    }
}
