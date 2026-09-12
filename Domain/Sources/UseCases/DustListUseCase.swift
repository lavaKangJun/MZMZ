//
//  DustListUseCase.swift
//  Domain
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation

public protocol DustListUseCaseProtocol {
    func getDustInfo() throws -> [DustStoreEntity]
    func deleteDustInfo(location: String) throws -> Bool
    func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity
}

public final class DustListUseCase: DustListUseCaseProtocol {
    private let repository: RepositoryProtocol
    
    public init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    public func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity {
        try await repository.nearestStationDustInfo(lat: lat, lng: lng)
    }
    
    public func getDustInfo() throws -> [DustStoreEntity] {
        try self.repository.getDustInfo()
    }
    
    public func deleteDustInfo(location: String) throws -> Bool {
        try self.repository.deleteDustInfo(location: location)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
