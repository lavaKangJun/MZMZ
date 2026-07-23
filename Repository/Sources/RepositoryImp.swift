//
//  RepositoryImp.swift
//  Repository
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation
import Domain
import Common

enum AppSecrets {
    static var airKoreaKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "AIR_KOREA_KEY") as? String,
              !key.isEmpty else {
            fatalError("AIR_KOREA_KEY 누락 — Secrets.xcconfig 확인")
        }
        return key
    }
}

public final class Repository: RepositoryProtocol {
    private let dataStore: DataStorable
    private let remote: RemoteProtocol
    
    public init(dataStore: DataStorable, remote: RemoteProtocol) {
        self.dataStore = dataStore
        self.remote = remote
    }
    
    public func fetchDust() -> [DustEntity] {
        return []
    }
    
    public func formatTMCoordinate(locationInfo: LocationInfoEntity, key: String) async throws -> [TMLocationInfoEntity] {
        var header = ["Authorization": "KakaoAK \(key)"]
        header["content-type"] = "application/json"
        var parameters: [String: String] = [:]
        parameters["x"] = locationInfo.longtitude
        parameters["y"] = locationInfo.latitude
        parameters["output_coord"] = "TM"
        
        let result: KakaoResponse<TMLocationInfo> = try await self.remote.request(header: header, endpoint: .tmLocation, method: .get, parameters: parameters)
       // print("formatTMCoordinate", result.documents)
        return result.documents.map { $0.makeEntity() }
    }
    
    public func fetchMsrstnList(tmX: Double, tmY: Double) async throws -> MsrstnListEntity {
        var parameters: [String: String] = [:]
        parameters["tmX"] = "\(tmX)"
        parameters["tmY"] = "\(tmY)"
        parameters["serviceKey"] = AppSecrets.airKoreaKey.removingPercentEncoding
        parameters["returnType"] = "json"
        parameters["ver"] = "1.1"
        
        let result: AirKoreaResponse<MsrstnList> = try await self.remote.request(header: nil, endpoint: .nearbyMsrstnList, method: .get, parameters: parameters)
        return result.response.body.makeEntity()
    }
    
    public func fetchMesureDnsty(stationName: String) async throws -> MesureDnstyListEntity {
        var parameters: [String: String] = [:]
        parameters["serviceKey"] = AppSecrets.airKoreaKey.removingPercentEncoding
        parameters["returnType"] = "json"
        parameters["ver"] = "1.1"
        parameters["stationName"] = stationName
        parameters["dataTerm"] = "DAILY"
        
        let result: AirKoreaResponse<MesureDnstyList> = try await self.remote.request(header: nil, endpoint: .msrstnAcctoRltmMesureDnsty, method: .get, parameters: parameters)
        return result.response.body.makeEntity(location: stationName)
    }
    
    public func findLocation(location: String, key: String) async throws -> [SearchLocationEntity] {
        var header = ["Authorization": "KakaoAK \(key)"]
        header["content-type"] = "application/json"
        
        var parameters: [String: String] = [:]
        parameters["analyze_type"] = "similar"
        parameters["query"] = location
        parameters["size"] = "5"
  
        let result: KakaoResponse<SearchLocationDTO> = try await self.remote.request(header: header, endpoint: .findLocation, method: .get, parameters: parameters)
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
                                            tmX: entity.tmX,
                                            tmY: entity.tmY,
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
}
