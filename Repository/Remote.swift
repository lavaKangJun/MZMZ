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

protocol RemoteProtocol {
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        parameters: [String : Any]
    ) async throws -> T
}

final class Remote: RemoteProtocol {
    private let session: Session
    private let header: HTTPHeaders? = nil
    
    init(session: Session) {
        self.session = session
    }
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        parameters: [String : Any]
    ) async throws -> T {
        let dataTask = self.session.request(
            endpoint.rawValue,
            method: method, 
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
