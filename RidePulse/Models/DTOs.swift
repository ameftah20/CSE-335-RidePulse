//
//  DTOs.swift
//  RidePulseApp
//
//  Created by Ahmed Saniad Meftah on 2/14/26.
//

import Foundation

struct StopDTO: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
}

struct ArrivalDTO: Identifiable, Codable, Hashable {
    let id: String
    let routeName: String
    let destination: String
    let minutes: Int
}
