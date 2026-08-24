//
//  Repository.swift
//  Domain
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation

public protocol RepositoryProtocol: Sendable {
    func findLocation(location: String, key: String) async throws -> [SearchLocationEntity]
    func getDustInfo() throws -> [DustStoreEntity]
    func setDustInfo(_ entity: DustStoreEntity) throws
    func deleteDustInfo(location: String) throws -> Bool
    func updateFavorite(location: String, isFavorite: Bool) throws
    func getFavoriteStatus(location: String) throws -> Bool
    func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity
}
