//
//  SearchLocationEntity.swift
//  Domain
//
//  Created by 강준영 on 2025/04/23.
//

import Foundation

public struct SearchLocationEntity {
    public let addressName: String
    public let longitude: String
    public let latitude: String
    
    public init(addressName: String, longitude: String, latitude: String) {
        self.addressName = addressName
        self.longitude = longitude
        self.latitude = latitude
    }
}
