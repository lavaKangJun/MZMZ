//
//  RepositoryImp.swift
//  Repository
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation
import Domain

public final class Repository: RepositoryProtocol {
    private let remote: RemoteProtocol
    private let airKoreaKey = "WpzhxSjZh2demmdSFRh4E%2BHd%2FHY27TmerkvFVRYMm38NVafozKEVZ%2FxDtfJobyTXI57jVadT%2FBkXAuvy7eqDSQ%3D%3D"
    
    public init(remote: RemoteProtocol) {
        self.remote = remote
    }
    
    public func fetchDust() -> [DustEntity] {
        return []
    }
    
    public func fetchMsrstnList(tmX: Double, tmY: Double) async throws -> MsrstnListEntity {
        var parameters: [String: Any] = [:]
        parameters["tmX"] = "\(tmX)"
        parameters["tmY"] = "\(tmX)"
        parameters["serviceKey"] = airKoreaKey.removingPercentEncoding
        parameters["returnType"] = "json"
        parameters["ver"] = "1.1"
        
        let result: AirKoreaResponse<MsrstnList> = try await self.remote.request(header: nil, endpoint: .nearbyMsrstnList, method: .get, parameters: parameters)
        return result.response.body.makeEntity()
    }
    
    public func fetchMesureDnsty(stationName: String) async throws -> MesureDnstyListEntity {
        var parameters: [String: Any] = [:]
        parameters["serviceKey"] = airKoreaKey.removingPercentEncoding
        parameters["returnType"] = "json"
        parameters["ver"] = "1.1"
        parameters["stationName"] = stationName
        parameters["dataTerm"] = "DAILY"
        
        let result: AirKoreaResponse<MesureDnstyList> = try await self.remote.request(header: nil, endpoint: .msrstnAcctoRltmMesureDnsty, method: .get, parameters: parameters)
        return result.response.body.makeEntity()
    }
    
    public func formatTMCoordinate(locationInfo: LocationInfoEntity, key: String) async throws -> [TMLocationInfoEntity] {
        var header = ["Authorization": "KakaoAK \(key)"]
        header["content-type"] = "application/json"
        var parameters: [String: Any] = [:]
        parameters["x"] = "\(locationInfo.longtitude)"
        parameters["y"] = "\(locationInfo.latitude)"
        parameters["output_coord"] = "TM"
        
        let result: TMLocationDocument = try await self.remote.request(header: header, endpoint: .tmLocation, method: .get, parameters: parameters)
        return result.documents.map { $0.makeEntity() }
    }
}
