//
//  MockLocationService.swift
//  MZMZTesting
//
//  Created by 강준영 on 10/23/25.
//  Copyright © 2025 Junyoung. All rights reserved.
//

import Foundation
import Domain

public class MockLocationService: LocationServiceProtocol, TestDouble {
    
    public init() { }
    
    public func getLocation() -> LocationInfoEntity? {
        self.resolve(LocationInfoEntity.self, name: "getLocation")
    }
}
