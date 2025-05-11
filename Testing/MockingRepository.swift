//
//  MockingRepository.swift
//  Testing
//
//  Created by 강준영 on 2025/03/17.
//

import Foundation
import Domain
import Repository

public final class MockingRepository: RepositoryProtocol {
    private let dataStore: DataStorable
    public init (dataStore: DataStorable) {
        self.dataStore = dataStore
    }
    
    public func findLocation(location: String, key: String) async throws -> [SearchLocationEntity] {
        return [
            SearchLocationEntity(addressName: "풍납동", longitude: "210720.00702229378", latitude: "448432.0990017229")
        ]
    }
    
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
        return [TMLocationInfoEntity(x: 204071.87806552797, y: 443752.1689259326)]
    }
    
    public func fetchMsrstnList(tmX: Double, tmY: Double) async throws -> MsrstnListEntity {
        return MsrstnListEntity(
            totalCount: 2,
            items: [
                MsrstnEntity(
                    stationCode: "111275",
                    tm: 2,
                    addr: "서울 강동구 천호대로 1151 길동사거리 강동성모요양병원 앞)",
                    stationName: "천호대로"
                ),
                MsrstnEntity(
                    stationCode: "111264",
                    tm: 1.6000000000000001,
                    addr: "서울특별시 서초구 강남대로 201 서초구민회관 앞 중앙차로 (양재동)",
                    stationName: "강남대로"
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
                    dataTime: "2025-05-11 10:00",
                    pm10Value: "68",
                    pm25Value: "45",
                    pm10Grade: Optional("2"),
                    pm25Grade: Optional("3"),
                    pm10Grade1h: nil,
                    pm25Grade1h: nil,
                    so2Value: "0.002",
                    coValue: "0.6",
                    o3Value: "0.033",
                    no2Value: "0.015"
                ),
                MesureDnstyEntity(
                    location: stationName,
                    dataTime: "2025-05-11 10:00",
                    pm10Value: "43",
                    pm25Value: "23",
                    pm10Grade: Optional("2"),
                    pm25Grade: Optional("2"),
                    pm10Grade1h: nil,
                    pm25Grade1h: nil,
                    so2Value: "0.002",
                    coValue: "0.5",
                    o3Value: "0.043",
                    no2Value: "0.015"
                )
            ]
        )
    }
    
    public func getDustInfo() -> [DustStoreEntity] {
        return self.dataStore.getDustInfo().map{ $0.makeEntity() }
    }
    
    public func setDustInfo(_ entity: DustStoreEntity) {
        self.dataStore.setDustInfo(
            DustStoreDTO(
                location: entity.location,
                longitude: entity.longitude,
                latitude: entity.latitude
            )
        )
    }
}
