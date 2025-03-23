//
//  Msrstn.swift
//  Domain
//
//  Created by 강준영 on 2025/03/23.
//

import Foundation

public struct AirKoreaResponse: Decodable {
    public let response: AirKoreaBody
}

public struct AirKoreaBody: Decodable {
    public let body: MsrstnList
}

public struct MsrstnList: Decodable {
    public let totalCount: Int
    public let item: [Msrstn]
    
    public init(totalCount: Int, item: [Msrstn]) {
        self.totalCount = totalCount
        self.item = item
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
}
