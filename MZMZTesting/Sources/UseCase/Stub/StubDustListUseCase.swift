//
//  StubDustListUseCase.swift
//  Testing
//
//  Created by 강준영 on 2025/03/29.
//

import Foundation
import Domain

public final class StubDustListUseCase: DustListUseCaseProtocol {
    private let repository: RepositoryProtocol
    private let locationService: LocationServiceProtocol
    
    public init(repository: RepositoryProtocol, locationService: LocationServiceProtocol) {
        self.repository = repository
        self.locationService = locationService
    }
    
    public func fetchLocation() async throws -> TMLocationInfoEntity? {
        guard let location = self.locationService.getLocation() else { return nil }
        let makeTMLocation = try await repository.formatTMCoordinate(locationInfo: location, key: "authKey")
        return makeTMLocation.first
    }
    
    public func fetchMesureDnsty(tmX: Double, tmY: Double) async throws -> MesureDnstyEntity? {
        guard let msrstn = try await repository.fetchMsrstnList(tmX: tmX, tmY: tmY).items.map({ $0.stationName }).first else {
            return nil
        }
        let mesureDnstyList = try await repository.fetchMesureDnsty(stationName: msrstn)
        return mesureDnstyList.items.first
    }
    
    public func convertoToTMCoordinate(location: LocationInfoEntity) async throws -> TMLocationInfoEntity? {
        let makeTMLocation = try await repository.formatTMCoordinate(locationInfo: location, key: "authKey")
        return makeTMLocation.last
    }
    
    public func getDustInfo() -> [DustStoreEntity] {
        do {
            return try repository.getDustInfo()
        } catch {
            print("Load Error", error)
            return []
        }
    }
    
    public func deleteDustInfo(location: String) -> Bool {
        return true
    }
}
