//
//  RepositoryImp.swift
//  Repository
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation
import Domain
import Common

public final class Repository: RepositoryProtocol {
    private let dataStore: DataStorable
    private let remote: RemoteProtocol
    
    public init(dataStore: DataStorable, remote: RemoteProtocol) {
        self.dataStore = dataStore
        self.remote = remote
    }
    
    public func findLocation(location: String) async throws -> [SearchLocationEntity] {
        // 우리 서버가 카카오 인증 헤더만 붙여 그대로 중계한다.
        // 파라미터는 카카오 로컬 API 규격 그대로 보낸다.
        var parameters: [String: String] = [:]
        parameters["analyze_type"] = "similar"
        parameters["query"] = location
        parameters["size"] = "5"

        let result: KakaoResponse<SearchLocationDTO> = try await self.remote.request(header: nil, endpoint: .findLocation, method: .get, parameters: parameters)
        return result.documents.map { $0.makeEntity() }
    }
    
    public func getDustInfo() throws -> [DustStoreEntity] {
        return try self.dataStore.load().map({ $0.makeEntity() })
    }
    
    public func setDustInfo(_ entity: DustStoreEntity) throws {
        try self.dataStore.insertTable(data:
                                        DustStoreDTO(
                                            location: entity.location,
                                            longitude: entity.longitude,
                                            latitude: entity.latitude,
                                            isFavorite: entity.isFavorite
                                        )
        )
    }
    
    public func deleteDustInfo(location: String) throws -> Bool {
        try self.dataStore.delete(location: location)
    }
    
    public func updateFavorite(location: String, isFavorite: Bool) throws {
        try self.dataStore.setFavorite(location: location, isFavorite: isFavorite)
    }
    
    public func getFavoriteStatus(location: String) throws -> Bool {
        try self.dataStore.getFavoriteStatus(location: location)
    }
    
    public func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity {
        var parameters: [String: String] = [:]
        parameters["lat"] = lat
        parameters["lng"] = lng
        
        return try await self.remote.request(header: nil, endpoint: .nearestStation, method: .get, parameters: parameters)
    }
}
