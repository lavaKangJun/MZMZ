//
//  TMLocationDocument.swift
//  Domain
//
//  Created by 강준영 on 2025/03/23.
//

import Foundation


public struct TMLocationInfoEntity {
    public let regionType: String
    public let x: Double
    public let y: Double
    
    public init(regionType: String, x: Double, y: Double) {
        self.regionType = regionType
        self.x = x
        self.y = y
    }
}

public struct LocationInfoEntity: Decodable {
    public let latitude: Double
    public let longtitude: Double
    
    public init(latitude: Double, longtitude: Double) {
        self.latitude = latitude
        self.longtitude = longtitude
    }
}
