//
//  MockDustListUseCase.swift
//  MZMZTesting
//
//  Created by 강준영 on 10/23/25.
//  Copyright © 2025 Junyoung. All rights reserved.
//

import Foundation
import Domain

public final class MockDustListUseCase: DustListUseCaseProtocol {
    public func fetchLocation() async throws -> Domain.TMLocationInfoEntity? {
        <#code#>
    }
    
    public func convertoToTMCoordinate(location: Domain.LocationInfoEntity) async throws -> Domain.TMLocationInfoEntity? {
        <#code#>
    }
    
    public func fetchMesureDnsty(tmX: Double, tmY: Double) async throws -> Domain.MesureDnstyEntity? {
        <#code#>
    }
    
    public func getDustInfo() -> [Domain.DustStoreEntity] {
        <#code#>
    }
    
    public func deleteDustInfo(location: String) -> Bool {
        <#code#>
    }
    
    
}
