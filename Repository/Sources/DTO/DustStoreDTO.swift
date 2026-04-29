//
//  DustStoreDTO.swift
//  Repository
//
//  Created by 강준영 on 2025/05/08.
//

import Foundation
import Domain

public struct DustStoreDTO: Equatable, Codable {
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

extension DustStoreDTO {
    public func makeEntity() -> DustStoreEntity {
        return DustStoreEntity(location: location, longitude: longitude, latitude: latitude, isFavorite: isFavorite)
    }
}
