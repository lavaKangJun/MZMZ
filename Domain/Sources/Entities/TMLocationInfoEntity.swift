//
//  TMLocationDocument.swift
//  Domain
//
//  Created by 강준영 on 2025/03/23.
//

import Foundation


public struct TMLocationInfoEntity {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct LocationInfoEntity: Decodable {
    public let latitude: String
    public let longtitude: String
    
    public init(latitude: String, longtitude: String) {
        self.latitude = latitude
        self.longtitude = longtitude
    }
}
