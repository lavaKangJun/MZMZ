//
//  Remote.swift
//  Repository
//
//  Created by 강준영 on 2025/03/17.
//

import Foundation
import Alamofire

enum Endpoint: String {
    case dustList = ""
}

enum RemoteAPIMethod {
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

protocol RemoteProtocol {
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: RemoteAPIMethod,
        parameters: [String : Any]
    ) async throws -> T
}

final class Remote: RemoteProtocol {
    private let session: Session = Session.default
    private let header: HTTPHeaders? = nil
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: RemoteAPIMethod,
        parameters: [String : Any]
    ) async throws -> T {
        let dataTask = self.session.request(
            endpoint.rawValue,
            method: method.httpMethod,
            parameters: parameters,
            headers: header
        ).serializingData()
        
        let response = await dataTask.response
        let result = response.result
        
        switch result {
        case let .success(data):
            let decodeResult = try JSONDecoder().decode(T.self, from: data)
            return decodeResult
        case let .failure(error):
            throw error
        }
    }
}
