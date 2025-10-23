//
//  MockRepository.swift
//  MZMZTesting
//
//  Created by 강준영 on 10/23/25.
//  Copyright © 2025 Junyoung. All rights reserved.
//

import Foundation
import Domain
import Repository

public final class MockRepository: RepositoryProtocol, TestDouble {
    public func fetchDust() -> [DustEntity] {
        resolve([DustEntity].self, name: "fetchDust") ?? []
    }
    
    public func formatTMCoordinate(locationInfo: Domain.LocationInfoEntity, key: String) async throws -> [TMLocationInfoEntity] {
        resolve([TMLocationInfoEntity].self, name: "formatTMCoordinate") ?? []
    }
    
    public func fetchMsrstnList(tmX: Double, tmY: Double) async throws -> MsrstnListEntity {
        resolve(MsrstnListEntity.self, name: "fetchMsrstnList") ?? MsrstnListEntity(totalCount: 0, items: [])
    }
    
    public func fetchMesureDnsty(stationName: String) async throws -> MesureDnstyListEntity {
        resolve(MesureDnstyListEntity.self, name: "fetchMesureDnsty") ?? MesureDnstyListEntity(totalCount: 0, items: [])
    }
    
    public func findLocation(location: String, key: String) async throws -> [Domain.SearchLocationEntity] {
        resolve([SearchLocationEntity].self, name: "findLocation") ?? []
    }
    
    public func getDustInfo() throws -> [DustStoreEntity] {
        resolve([DustStoreEntity].self, name: "getDustInfo") ?? []
    }
    
    public func setDustInfo(_ entity: DustStoreEntity) throws {
        verify(name: "setDustInfo", args: entity)
    }
    
    public func deleteDustInfo(location: String) throws -> Bool {
        resolve(Bool.self, name: "deleteDustInfo") ?? false
    }
}

