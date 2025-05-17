//
//  DustListUseCase.swift
//  Domain
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation

public protocol DustListUseCaseProtocol {
    func fetchLocation() async throws -> TMLocationInfoEntity?
    func convertoToTMCoordinate(latitude: Double, longtitude: Double) async throws -> TMLocationInfoEntity?
    func fetchMesureDnsty(tmX: Double, tmY: Double) async throws -> MesureDnstyEntity?
    func getDustInfo() -> [DustStoreEntity]
}

public final class DustListUseCase: DustListUseCaseProtocol {
    private let repository: RepositoryProtocol
    private let locationService: LocationServiceProtocol
    private let authKey = "16f1ed764daa4d2c4d6e3f0d25269ca5"
    
    public init(repository: RepositoryProtocol, locationService: LocationServiceProtocol) {
        self.repository = repository
        self.locationService = locationService
    }
    
    public func fetchLocation() async throws -> TMLocationInfoEntity? {
        guard let location = self.locationService.getLocation() else { return nil }
        let makeTMLocation = try await repository.formatTMCoordinate(locationInfo: location, key: authKey)
        return makeTMLocation.last
    }
    
    public func convertoToTMCoordinate(latitude: Double, longtitude: Double) async throws -> TMLocationInfoEntity? {
        let makeTMLocation = try await repository.formatTMCoordinate(locationInfo: .init(latitude: latitude, longtitude: longtitude), key: authKey)
        return makeTMLocation.last
    }
    
    public func fetchMesureDnsty(tmX: Double, tmY: Double) async throws -> MesureDnstyEntity? {
        guard let msrstn = try await repository.fetchMsrstnList(tmX: tmX, tmY: tmY).items.map({ $0.stationName }).first else {
            return nil
        }
        let mesureDnstyList = try await repository.fetchMesureDnsty(stationName: msrstn)
        return mesureDnstyList.items.first
    }
    
    public func getDustInfo() -> [DustStoreEntity] {
        do {
            return try self.repository.getDustInfo()
        } catch {
            print("Load Error", error)
            return []
        }
    }
}
