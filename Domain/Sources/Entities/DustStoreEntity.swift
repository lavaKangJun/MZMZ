//
//  DustStoreEntity.swift
//  Domain
//
//  Created by 강준영 on 2025/05/08.
//

import Foundation

public struct DustStoreEntity {
    public let location: String
    public let longitude: String
    public let latitude: String

    public init(location: String, longitude: String, latitude: String) {
        self.location = location
        self.longitude = longitude
        self.latitude = latitude
    }
}
