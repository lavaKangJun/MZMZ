//
//  DustEntity.swift
//  Domain
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation

public struct DustEntity {
    public let location: String
    public let dust: String
    public let microDust: String
    
    public init(location: String, dust: String, microDust: String) {
        self.location = location
        self.dust = dust
        self.microDust = microDust
    }
}
