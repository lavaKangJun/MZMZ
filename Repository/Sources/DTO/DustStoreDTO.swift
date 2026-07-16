//
//  DustStoreDTO.swift
//  Repository
//
//  Created by 강준영 on 2025/05/08.
//

import Foundation
import Domain

public struct DustStoreDTO: Equatable, Codable, Sendable {
    public let location: String
    public let longitude: String
    public let latitude: String
    public let isFavorite: Bool
    public let tmX: Double?
    public let tmY: Double?
    
    public init(
        location: String,
        longitude: String,
        latitude: String,
        tmX: Double?,
        tmY: Double?,
        isFavorite: Bool,
    ) {
        self.location = location
        self.longitude = longitude
        self.latitude = latitude
        self.isFavorite = isFavorite
        self.tmX = tmX
        self.tmY = tmY
    }
}

extension DustStoreDTO {
    public func makeEntity() -> DustStoreEntity {
        return DustStoreEntity(location: location, longitude: longitude, latitude: latitude, tmX: tmX, tmY: tmY, isFavorite: isFavorite)
    }
}
