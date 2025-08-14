//
//  DustListUseCase.swift
//  Domain
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation

public protocol DustListUseCaseProtocol {
    func fetchLocation() async throws -> TMLocationInfoEntity?
    func convertoToTMCoordinate(location: LocationInfoEntity) async throws -> TMLocationInfoEntity?
    func fetchMesureDnsty(tmX: Double, tmY: Double) async throws -> MesureDnstyEntity?
    func getDustInfo() -> [DustStoreEntity]
    func deleteDustInfo(location: String) -> Bool
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
    
    public func convertoToTMCoordinate(location: LocationInfoEntity) async throws -> TMLocationInfoEntity? {
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
    
    public func getDustInfo() -> [DustStoreEntity] {
        do {
            return try self.repository.getDustInfo()
        } catch {
            print("Load Error", error)
            return []
        }
    }
    
    public func deleteDustInfo(location: String) -> Bool {
        do {
            return try self.repository.deleteDustInfo(location: location)
        } catch {
            print("delete fail", error)
            return false
        }
        
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
