//
//  SearchLocationDTO.swift
//  Repository
//
//  Created by 강준영 on 2025/04/23.
//

import Foundation
import Domain

public struct SearchLocationDTO: Decodable {
    public let addressName: String
    public let longitude: String //x
    public let latitude: String // y
    
    enum CodingKeys: String, CodingKey {
        case longitude = "x"
        case latitude = "y"
        case addressName = "address_name"
    }
    
    public func makeEntity() -> SearchLocationEntity {
        return SearchLocationEntity(addressName: addressName, longitude: longitude, latitude: latitude)
    }
}
