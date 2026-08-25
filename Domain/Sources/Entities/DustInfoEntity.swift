//
//  DustInfoEntity.swift
//  Domain
//
//  Created by 강준영 on 8/24/26.
//  Copyright © 2026 Junyoung. All rights reserved.
//

import Foundation

public struct DustInfoEntity: Decodable {
    public let stationName: String
    public let pm10Value: Int?
    public let pm25Value: Int?
    public let dataTime: String?
    public let distanceKm: Double
    public let sido: String
    public let addr: String
}

extension DustInfoEntity {
    public init() {
        self.stationName = ""
        self.addr = ""
        self.dataTime = nil
        self.sido = ""
        self.pm10Value = nil
        self.pm25Value = nil
        self.distanceKm = 0.0
    }
}
