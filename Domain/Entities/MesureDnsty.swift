//
//  MesureDnsty.swift
//  Domain
//
//  Created by 강준영 on 2025/03/28.
//

import Foundation

public struct MesureDnstyListEntity {
    public let totalCount: Int
    public let items: [MesureDnstyEntity]
    
    public init(totalCount: Int, items: [MesureDnstyEntity]) {
        self.totalCount = totalCount
        self.items = items
    }
}

public struct MesureDnstyEntity {
    public let location: String
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
        location: String,
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
        self.location = location
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
    
    private func translateDustGrade(_ value: String) -> Int {
        guard let gradeValue = Int(value) else { return 0 }
        if -1 == gradeValue {
            return -1
        } else if 0...30 ~= gradeValue {
            return 0
        } else if 31...80 ~= gradeValue {
            return 1
        } else if 81...150 ~= gradeValue {
            return 2
        } else {
            return 3
        }
    }
    
    private func translateMicroDustGrade(_ value: String) -> Int {
        guard let gradeValue = Int(value) else { return 0 }
        if -1 == gradeValue {
            return -1
        } else if 0...15 ~= gradeValue {
            return 0
        } else if 16...50 ~= gradeValue {
            return 1
        } else if 50...100 ~= gradeValue {
            return 2
        } else {
            return 3
        }
    }
    
    public var dustGradeText: String {
        let gradeValue = Int(translateDustGrade(self.pm10Value))
        if gradeValue == -1 {
            return "점검중"
        } else if 0...30 ~= gradeValue {
            return "좋음"
        } else if 31...80 ~= gradeValue {
            return "보통"
        } else if 81...150 ~= gradeValue {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
    }
    
    public var microDustGradeText: String {
        let gradeValue = Int(translateMicroDustGrade(self.pm25Value))
        if gradeValue == -1 {
            return "점검중"
        } else if 0...15 ~= gradeValue {
            return "좋음"
        } else if 16...50 ~= gradeValue {
            return "보통"
        } else if 51...100 ~= gradeValue {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
    }
}
