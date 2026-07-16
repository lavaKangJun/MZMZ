//
//  DustStoreEntity.swift
//  Domain
//
//  Created by 강준영 on 2025/05/08.
//

import Foundation

public struct DustStoreEntity: Sendable {
    public let location: String
    public let longitude: String
    public let latitude: String
    public let tmX: Double?
    public let tmY: Double?
    public let isFavorite: Bool

    public init(
        location: String,
        longitude: String,
        latitude: String,
        tmX: Double?,
        tmY: Double?,
        isFavorite: Bool
    ) {
        self.location = location
        self.longitude = longitude
        self.latitude = latitude
        self.tmX = tmX
        self.tmY = tmY
        self.isFavorite = isFavorite
    }
}
