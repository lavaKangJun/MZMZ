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
    
    public init(remote: RemoteProtocol) {
        self.remote = remote
    }
    
    public func fetchDust() -> [DustEntity] {
        return []
    }
    
    public func formatTMCoordinate(locationInfo: LocationInfo, key: String) async throws -> [TMLocationInfo] {
        var parameters: [String: Any] = [:]
        parameters["x"] = "\(locationInfo.longtitude)"
        parameters["y"] = "\(locationInfo.latitude)"
        parameters["output_coord"] = "TM"
        var header = ["Authorization": "KakaoAK \(key)"]
        header["content-type"] = "application/json"
        let result: TMLocationDocument = try await self.remote.request(header: header, endpoint: .tmLocation, method: .get, parameters: parameters)
        return result.documents
    }
}
