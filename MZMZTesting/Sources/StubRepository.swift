//
//  StubRepository.swift
//  Testing
//
//  Created by 강준영 on 2025/03/17.
//

import Foundation
import Domain
import Repository

public final class StubRepository: RepositoryProtocol {
    private let dataStore: DataStorable
    public init (dataStore: DataStorable) {
        self.dataStore = dataStore
    }
    
    public func findLocation(location: String, key: String) async throws -> [SearchLocationEntity] {
        return [
            SearchLocationEntity(addressName: location, longitude: "127.115731280691", latitude: "37.529239225114 ")
        ]
    }
    
    public func getDustInfo() -> [DustStoreEntity] {
        return []
    }
    
    public func setDustInfo(_ entity: DustStoreEntity) {
    }
    
    public func deleteDustInfo(location: String) throws -> Bool {
        return true
    }
    
    public func updateFavorite(location: String, isFavorite: Bool) throws {
        
    }
    
    public func getFavoriteStatus(location: String) throws -> Bool {
        return false
    }
    
    public func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity {
        return DustInfoEntity()
    }
}
