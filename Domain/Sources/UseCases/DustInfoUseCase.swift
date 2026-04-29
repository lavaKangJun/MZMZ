//
//  DustInfoUseCase.swift
//  Domain
//
//  Created by 강준영 on 2025/05/05.
//

import Foundation

public protocol DustInfoUseCaseProtocol {
    func convertToTMCoordinate(location: LocationInfoEntity) async throws -> TMLocationInfoEntity?
    func fetchMesureDnsty(tmX: Double, tmY: Double) async throws -> MesureDnstyEntity?
    func saveDustInfo(location: String, longitude: String, latitude: String, isFavorite: Bool)
    func updateFavorite(location: String, isFavorite: Bool) throws
    func getFavoriteStatus(location: String) throws -> Bool
}

public final class DustInfoUseCase: DustInfoUseCaseProtocol {
    private let repository: RepositoryProtocol
    private let authKey = "16f1ed764daa4d2c4d6e3f0d25269ca5"
    
    public init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    public func convertToTMCoordinate(location: LocationInfoEntity) async throws -> TMLocationInfoEntity? {
        let makeTMLocation = try await repository.formatTMCoordinate(locationInfo: location, key: authKey)
        return makeTMLocation.last
    }
    
    public func fetchMesureDnsty(tmX: Double, tmY: Double) async throws -> MesureDnstyEntity? {
        let msrstns = try await repository.fetchMsrstnList(tmX: tmX, tmY: tmY).items.map({ $0.stationName })
        for index in 0..<msrstns.count {
            if let firstStation = msrstns[safe: index] {
                let mesureDnstyList = try await repository.fetchMesureDnsty(stationName: firstStation)
                if let mesureDnsty = mesureDnstyList.items.first(where: { ($0.pm10Value != "-") && ($0.pm25Value != "-") }) {
                    return mesureDnsty
                } else {
                    continue
                }
            }
        }
        return nil
    }
    
    public func saveDustInfo(
        location: String,
        longitude: String,
        latitude: String,
        isFavorite: Bool
    ) {
        do {
            try self.repository.setDustInfo(DustStoreEntity(location: location, longitude: longitude, latitude: latitude, isFavorite: isFavorite))
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
