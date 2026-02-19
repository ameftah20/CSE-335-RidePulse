//
//  Models.swift
//  RidePulseApp
//
//  Created by Ahmed Saniad Meftah on 2/14/26.
//

import Foundation
import SwiftData

@Model
final class FavoriteStop: Identifiable {
    var id: String
    var name: String
    var createdAt: Date

    init(id: String, name: String, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}

@Model
final class RideCheckIn: Identifiable {
    var id: UUID
    var stopId: String
    var stopName: String
    var qrPayload: String
    var timestamp: Date

    init(stopId: String, stopName: String, qrPayload: String, timestamp: Date = .now) {
        self.id = UUID()
        self.stopId = stopId
        self.stopName = stopName
        self.qrPayload = qrPayload
        self.timestamp = timestamp
    }
}
