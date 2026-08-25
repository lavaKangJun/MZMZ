//
//  MockDustListUseCase.swift
//  MZMZTesting
//
//  Created by 강준영 on 10/23/25.
//  Copyright © 2025 Junyoung. All rights reserved.
//

import Foundation
import Domain

public final class MockDustListUseCase: DustListUseCaseProtocol, TestDouble {
    public init() { }
    
    public func getDustInfo() throws -> [DustStoreEntity] {
        try resolveWithThrows([DustStoreEntity].self, name: "getDustInfo") ?? []
    }
    
    public func deleteDustInfo(location: String) -> Bool {
        resolve(Bool.self, name: "deleteDustInfo") ?? false
    }
    
    public func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity {
        try resolveWithThrows(DustInfoEntity.self, name: "nearestStationDustInfo") ?? DustInfoEntity()
    }
}
