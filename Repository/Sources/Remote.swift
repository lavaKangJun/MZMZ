//
//  Remote.swift
//  Repository
//
//  Created by 강준영 on 2025/03/17.
//

import Foundation
import Alamofire
import FirebaseAppCheck

public enum Endpoint: String {
    case dustList = ""
    case tmLocation = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json"
    case nearbyMsrstnList = "http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList"
    case msrstnAcctoRltmMesureDnsty = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
    case findLocation = "https://dapi.kakao.com/v2/local/search/address.json"
    case nearestStation = "https://asia-northeast3-mzmz-392b7.cloudfunctions.net/nearestStation"

    /// App Check 토큰을 붙여야 하는(= 우리가 만든) 엔드포인트인지.
    var isOwnServer: Bool {
        switch self {
        case .nearestStation:
            return true
        case .dustList, .tmLocation, .nearbyMsrstnList,
             .msrstnAcctoRltmMesureDnsty, .findLocation:
            return false
        }
    }
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

public protocol RemoteProtocol: Sendable {
    func request<T: Decodable>(
        header: [String : String]?,
        endpoint: Endpoint,
        method: RemoteAPIMethod,
        parameters: [String : String]
    ) async throws -> T
}

public final class Remote: RemoteProtocol {
    private let session: Session = Session(serializationQueue: DispatchQueue(label: "Alamofire.serialization"))
    
    public init() { }
    
    public func request<T: Decodable>(
        header: [String : String]?,
        endpoint: Endpoint,
        method: RemoteAPIMethod,
        parameters: [String : String]
    ) async throws -> T {
        var headers = header ?? [:]
        // 우리 서버로 가는 요청에만 붙인다. 카카오/에어코리아는 남의 서버라
        // 토큰을 보낼 이유가 없다.
        if endpoint.isOwnServer, let token = await Self.appCheckToken() {
            headers["X-Firebase-AppCheck"] = token
        }

        let dataTask = self.session.request(
            endpoint.rawValue,
            method: method.httpMethod,
            parameters: parameters,
            headers: headers.isEmpty ? nil : HTTPHeaders(headers)
        ).serializingData()
        
        let response = await dataTask.response
        let result = response.result
        switch result {
        case let .success(data):
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📦\(endpoint) Response JSON:\n\(jsonString)")
//            }
            let decodeResult = try JSONDecoder().decode(T.self, from: data)
            return decodeResult
        case let .failure(error):
            throw error
        }
    }

    /// App Check 토큰을 가져온다.
    ///
    /// 실패해도 요청 자체는 보낸다. 서버가 아직 검증을 강제하지 않는
    /// 동안에는 통과하고, 강제한 뒤에는 서버가 401 로 판단한다.
    private static func appCheckToken() async -> String? {
        do {
            return try await AppCheck.appCheck().token(forcingRefresh: false).token
        } catch {
            print("App Check 토큰 발급 실패", error)
            return nil
        }
    }
}
