//
//  TMLocatioDTO.swift
//  Repository
//
//  Created by 강준영 on 2025/03/24.
//

import Foundation
import Domain
public struct KakaoResponse<T: Decodable>: Decodable {
    public let documents: [T]
}

public struct TMLocationInfo: Decodable {
    public enum RegionType: String, Decodable {
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
    
    func makeEntity() -> TMLocationInfoEntity {
        return TMLocationInfoEntity(x: x, y: y)
    }
}
