//
//  Remote.swift
//  Repository
//
//  Created by 강준영 on 2025/03/17.
//

import Foundation
import os
import Alamofire
import FirebaseAppCheck

public enum Endpoint: String {
    /// 주소 검색. 카카오 로컬 API 를 우리 서버가 대신 호출한다.
    ///
    /// 예전에는 앱이 dapi.kakao.com 을 직접 불렀는데, 그러려면 카카오 REST 키를
    /// Info.plist 에 넣어야 했다. Info.plist 는 .ipa 안에 평문으로 들어가
    /// 누구나 꺼내 쓸 수 있고, 그러면 우리 쿼터가 소진된다.
    /// 키를 서버에만 두고 앱은 App Check 토큰으로 신원을 증명한다.
    case findLocation = "https://asia-northeast3-mzmz-392b7.cloudfunctions.net/searchAddress"
    case nearestStation = "https://asia-northeast3-mzmz-392b7.cloudfunctions.net/nearestStation"

    /// App Check 토큰을 붙여야 하는(= 우리가 만든) 엔드포인트인지.
    ///
    /// 지금은 둘 다 우리 서버다. 남의 서버를 직접 부르는 경로가 다시 생기면
    /// 그때 false 를 돌려주면 된다.
    var isOwnServer: Bool {
        switch self {
        case .nearestStation, .findLocation:
            return true
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

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "MZMZ",
        category: "AppCheck"
    )

    /// App Check 토큰을 가져온다.
    ///
    /// 실패하면 헤더 없이 보내고 서버가 401 로 끊는다.
    private static func appCheckToken() async -> String? {
        do {
            return try await AppCheck.appCheck()
                .token(forcingRefresh: false).token
        } catch {
            // print 는 통합 로그에 안 남아 TestFlight 빌드에서 볼 수 없다.
            logger.error("App Check 토큰 발급 실패: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}
