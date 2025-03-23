//
//  TMLocationDocument.swift
//  Domain
//
//  Created by 강준영 on 2025/03/23.
//

import Foundation

public struct LocationInfo: Decodable {
    public let latitude: Double
    public let longtitude: Double
}

public struct TMLocationDocument: Decodable {
    public let documents: [TMLocationInfo]
}

public struct TMLocationInfo: Decodable {
    public enum regionType: String, Decodable {
        case H = "H"
        case B = "B"
    }
    
    public let regionType: String
    public let x: Double
    public let y: Double
    
    enum CodingKeys: String, CodingKey {
        case x
        case y
        case regionType = "region_type"
    }
}
