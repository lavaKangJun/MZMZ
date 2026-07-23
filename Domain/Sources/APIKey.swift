//
//  APIKey.swift
//  Domain
//
//  Created by 강준영 on 7/23/26.
//  Copyright © 2026 Junyoung. All rights reserved.
//
import Foundation

enum AppSecrets {
    static var kakaoRestKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_REST_KEY") as? String,
              !key.isEmpty else {
            fatalError("KAKAO_REST_KEY 누락")
        }
        return key
    }
}
