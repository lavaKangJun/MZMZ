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
    public let isFavorite: Bool

    public init(location: String, longitude: String, latitude: String, isFavorite: Bool) {
        self.location = location
        self.longitude = longitude
        self.latitude = latitude
        self.isFavorite = isFavorite
    }
}
