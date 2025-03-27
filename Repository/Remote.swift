//
//  Remote.swift
//  Repository
//
//  Created by 강준영 on 2025/03/17.
//

import Foundation
import Alamofire

public enum Endpoint: String {
    case dustList = ""
    case tmLocation = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json"
    case nearbyMsrstnList = "http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList"
    case msrstnAcctoRltmMesureDnsty = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
}

public enum RemoteAPIMethod {
    case get
    case put
    case delete
    case post
    
    var httpMethod: HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
}

public protocol RemoteProtocol {
    func request<T: Decodable>(
        header: [String : String]?,
        endpoint: Endpoint,
        method: RemoteAPIMethod,
        parameters: [String : Any]
    ) async throws -> T
}

public final class Remote: RemoteProtocol {
    private let session: Session = Session.default
    
    public init() {
        
    }
    
    public func request<T: Decodable>(
        header: [String : String]?,
        endpoint: Endpoint,
        method: RemoteAPIMethod,
        parameters: [String : Any]
    ) async throws -> T {
        let dataTask = self.session.request(
            endpoint.rawValue,
            method: method.httpMethod,
            parameters: parameters,
            headers: header.map { HTTPHeaders($0) }
        ).serializingData()
        
        let response = await dataTask.response
        let result = response.result
        switch result {
        case let .success(data):
            let json = try JSONSerialization.jsonObject(with: data)
            print(json)
            let decodeResult = try JSONDecoder().decode(T.self, from: data)
            return decodeResult
        case let .failure(error):
            print(endpoint, error)
            throw error
        }
    }
}
