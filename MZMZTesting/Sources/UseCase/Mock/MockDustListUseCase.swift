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
    
    public func fetchLocation() async throws -> TMLocationInfoEntity? {
        resolve(TMLocationInfoEntity.self, name: "fetchLocation")
    }
    
    public func convertoToTMCoordinate(location: Domain.LocationInfoEntity) async throws -> TMLocationInfoEntity? {
        resolve(TMLocationInfoEntity.self, name: "convertoToTMCoordinate")
    }
    
    public func fetchMesureDnsty(tmX: Double, tmY: Double) async throws -> MesureDnstyEntity? {
        resolve(MesureDnstyEntity.self, name: "fetchMesureDnsty")
    }
    
    public func getDustInfo() throws -> [DustStoreEntity] {
        try resolveWithThrows([DustStoreEntity].self, name: "getDustInfo") ?? []
    }
    
    public func deleteDustInfo(location: String) -> Bool {
        resolve(Bool.self, name: "deleteDustInfo") ?? false
    }
}
