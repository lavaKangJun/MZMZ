//
//  Repository.swift
//  Domain
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation

public protocol RepositoryProtocol {
    func fetchDust() -> [DustEntity]
    
    func formatTMCoordinate(locationInfo: LocationInfo, key: String) async throws -> [TMLocationInfo]
}
