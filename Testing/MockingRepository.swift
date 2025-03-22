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
    
    public func formatTMCoordinate(locationInfo: Domain.LocationInfo, key: String) async throws -> [Domain.TMLocationInfo] {
        return []
    }
}
