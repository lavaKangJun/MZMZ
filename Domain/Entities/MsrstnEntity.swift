//
//  Msrstn.swift
//  Domain
//
//  Created by 강준영 on 2025/03/23.
//

import Foundation

public struct MsrstnListEntity {
    public let totalCount: Int
    public let items: [MsrstnEntity]
    
    public init(totalCount: Int, items: [MsrstnEntity]) {
        self.totalCount = totalCount
        self.items = items
    }
}

public struct MsrstnEntity: Decodable {
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
