//
//  DTO.swift
//  Repository
//
//  Created by 강준영 on 2025/03/24.
//

import Foundation
import Domain

public struct AirKoreaResponse<T: Decodable>: Decodable {
    public let response: AirKoreaBody<T>
}

public struct AirKoreaBody<T: Decodable>: Decodable {
    public let body: T
}

public struct MsrstnList: Decodable {
    public let totalCount: Int
    public let items: [Msrstn]
    
    public init(totalCount: Int, items: [Msrstn]) {
        self.totalCount = totalCount
        self.items = items
    }
    
    func makeEntity() -> MsrstnListEntity {
        return MsrstnListEntity(totalCount: totalCount, items: items.map { $0.makeEntity() })
    }
}

public struct Msrstn: Decodable {
    public let stationCode: String
    public let tm: Double
    public let addr: String
    public let stationName: String
    
    public init(stationCode: String, tm: Double, addr: String, stationName: String) {
        self.stationCode = stationCode
        self.tm = tm
        self.addr = addr
        self.stationName = stationName
    }
    
    func makeEntity() -> MsrstnEntity {
        return MsrstnEntity(stationCode: stationCode, tm: tm, addr: addr, stationName: stationName)
    }
}
