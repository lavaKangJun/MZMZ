//
//  MesureDnstyDTO.swift
//  Repository
//
//  Created by 강준영 on 2025/03/28.
//

import Foundation
import Domain

public struct MesureDnstyList: Decodable {
    public let totalCount: Int
    public let items: [MesureDnsty]
    
    public init(totalCount: Int, items: [MesureDnsty]) {
        self.totalCount = totalCount
        self.items = items
    }
    
    func makeEntity() -> MesureDnstyListEntity {
        return MesureDnstyListEntity(totalCount: totalCount, items: items.map { $0.makeEntity() })
    }
}

public struct MesureDnsty: Decodable {
    public let dataTime: String
    public let pm10Value: String // 미세먼지 농도
    public let pm25Value: String //초미세먼지 농도
    public let pm10Grade: String? // 미세먼지 24시간 등금
    public let pm25Grade: String? // 초미세먼지 24시간 등급
    public let pm10Grade1h: String? // 미세먼지 1시간 등급
    public let pm25Grade1h: String? // 초미세전지 1시간 등급
    public let so2Value: String // 아황산가스 농도
    public let coValue: String // 일산화탄소 농도
    public let o3Value: String // 오존 농도
    public let no2Value: String // 이산화질소
    
    public init(
        dataTime: String,
        pm10Value: String,
        pm25Value: String,
        pm10Grade: String?,
        pm25Grade: String?,
        pm10Grade1h: String?,
        pm25Grade1h: String?,
        so2Value: String,
        coValue: String,
        o3Value: String,
        no2Value: String
    ) {
        self.dataTime = dataTime
        self.pm10Value = pm10Value
        self.pm25Value = pm25Value
        self.pm10Grade = pm10Grade
        self.pm25Grade = pm25Grade
        self.pm10Grade1h = pm10Grade1h
        self.pm25Grade1h = pm25Grade1h
        self.so2Value = so2Value
        self.coValue = coValue
        self.o3Value = o3Value
        self.no2Value = no2Value
    }
    
    func makeEntity() -> MesureDnstyEntity {
        return MesureDnstyEntity(
            dataTime: dataTime,
            pm10Value: pm10Value,
            pm25Value: pm25Value,
            pm10Grade: pm10Grade,
            pm25Grade: pm25Grade,
            pm10Grade1h: pm10Grade1h,
            pm25Grade1h: pm25Grade1h,
            so2Value: so2Value,
            coValue: coValue,
            o3Value: o3Value,
            no2Value: no2Value
        )
    }
}
