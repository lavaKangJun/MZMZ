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
        return []
    }
    
    public func fetchMsrstnList(tmX: Double, tmY: Double) async throws -> MsrstnListEntity {
        return MsrstnListEntity(totalCount: 0, items: [])
    }
    
    public func fetchMesureDnsty(stationName: String) async throws -> MesureDnstyListEntity {
        return MesureDnstyListEntity(totalCount: 0, items: [])
    }
}
