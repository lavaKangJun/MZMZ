//
//  DustInfoUseCase.swift
//  Domain
//
//  Created by 강준영 on 2025/05/05.
//

import Foundation

public protocol DustInfoUseCaseProtocol: Sendable {
    func saveDustInfo(location: String, longitude: String, latitude: String, tmX: Double, tmY: Double, isFavorite: Bool)
    func updateFavorite(location: String, isFavorite: Bool) throws
    func getFavoriteStatus(location: String) throws -> Bool
    func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity
}

public final class DustInfoUseCase: DustInfoUseCaseProtocol {
    private let repository: RepositoryProtocol
    private let authKey = AppSecrets.kakaoRestKey
    
    public init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    public func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity {
        return try await repository.nearestStationDustInfo(lat: lat, lng: lng)
    }
    
    public func saveDustInfo(
        location: String,
        longitude: String,
        latitude: String,
        tmX: Double,
        tmY: Double,
        isFavorite: Bool
    ) {
        do {
            try self.repository.setDustInfo(
                DustStoreEntity(
                    location: location,
                    longitude: longitude,
                    latitude: latitude,
                    tmX: tmX,
                    tmY: tmY,
                    isFavorite: isFavorite
                )
            )
        } catch {
            print("save Error", error)
        }
        
    }
    
    public func updateFavorite(location: String, isFavorite: Bool) throws {
        try self.repository.updateFavorite(location: location, isFavorite: isFavorite)
    }
    
    public func getFavoriteStatus(location: String) throws -> Bool {
        try self.repository.getFavoriteStatus(location: location)
    }
}
