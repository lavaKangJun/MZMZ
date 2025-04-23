//
//  Repository.swift
//  Domain
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation

public protocol RepositoryProtocol {
    func fetchDust() -> [DustEntity]
    func formatTMCoordinate(locationInfo: LocationInfoEntity, key: String) async throws -> [TMLocationInfoEntity]
    func fetchMsrstnList(tmX: Double, tmY: Double) async throws -> MsrstnListEntity
    func fetchMesureDnsty(stationName: String) async throws -> MesureDnstyListEntity
    func findLocation(location: String, key: String) async throws -> [SearchLocationEntity]
}
