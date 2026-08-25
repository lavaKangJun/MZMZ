//
//  DustListUseCase.swift
//  Domain
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation

public protocol DustListUseCaseProtocol {
    func getDustInfo() throws -> [DustStoreEntity]
    func deleteDustInfo(location: String) -> Bool
    func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity
}

public final class DustListUseCase: DustListUseCaseProtocol {
    private let repository: RepositoryProtocol
    private let authKey = AppSecrets.kakaoRestKey
    
    public init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    public func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity {
        return try await repository.nearestStationDustInfo(lat: lat, lng: lng)
    }
    
    public func getDustInfo() throws -> [DustStoreEntity] {
        do {
            return try self.repository.getDustInfo()
        } catch {
            print("Load Error", error)
            throw error
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
