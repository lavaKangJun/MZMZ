//
//  TMLocatioDTO.swift
//  Repository
//
//  Created by 강준영 on 2025/03/24.
//

import Foundation
import Domain
public struct KakaoResponse<T: Decodable>: Decodable {
    public let documents: [T]
}
