//
//  MockingRepository.swift
//  Testing
//
//  Created by 강준영 on 2025/03/17.
//

import Foundation
import Domain

public final class MockingRepository: RepositoryProtocol {
    public init () { }
    
    public func fetchDust() -> [DustEntity] {
        return [
            DustEntity(
                location: "풍납동",
                dust: "좋음",
                microDust: "나쁨"
            ),
            DustEntity(
                location: "역삼동",
                dust: "보통",
                microDust: "보통"
            )
            ]
        }
    
    public func formatTMCoordinate(locationInfo: LocationInfoEntity, key: String) async throws -> [TMLocationInfoEntity] {
        return [TMLocationInfoEntity(  x: 210720.00702229378, y: 448432.0990017229)]
    }
    
    public func fetchMsrstnList(tmX: Double, tmY: Double) async throws -> MsrstnListEntity {
        return MsrstnListEntity(
            totalCount: 2,
            items: [
                MsrstnEntity(
                    stationCode: "735381",
                    tm: 3.4,
                    addr: "전북특별자치도 순창군 순창읍 경천로 33 순창군청 3층 옥상",
                    stationName: "순창읍"
                ),
                MsrstnEntity(
                    stationCode: "336151",
                    tm: 16.2,
                    addr: "전남 담양군 담양읍 면앙정로 730 담양군 농업기술센터 생명농업연구동 뒤편",
                    stationName: "담양읍"
                )
            ]
        )
    }
    
    public func fetchMesureDnsty(
        stationName: String
    ) async throws -> MesureDnstyListEntity {
        return MesureDnstyListEntity(
            totalCount: 2,
            items: [
                MesureDnstyEntity(
                    location: stationName,
                    dataTime: "2025-03-29 22:00",
                    pm10Value: "16",
                    pm25Value: "5",
                    pm10Grade: Optional("1"),
                    pm25Grade: Optional("1"),
                    pm10Grade1h: nil,
                    pm25Grade1h: nil,
                    so2Value: "0.002",
                    coValue: "0.2",
                    o3Value: "0.040",
                    no2Value: "0.004"
                ),
                MesureDnstyEntity(
                    location: stationName,
                    dataTime: "2025-03-29 21:00",
                    pm10Value: "23",
                    pm25Value: "5",
                    pm10Grade: Optional("1"),
                    pm25Grade: Optional("1"),
                    pm10Grade1h: nil,
                    pm25Grade1h: nil,
                    so2Value: "0.002",
                    coValue: "0.2",
                    o3Value: "0.041",
                    no2Value: "0.004"
                )
            ]
        )
    }
}
