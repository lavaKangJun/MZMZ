//
//  StubDustListUseCase.swift
//  Testing
//
//  Created by 강준영 on 2025/03/29.
//

import Foundation
import Domain

public final class StubDustListUseCase: DustListUseCaseProtocol {
    private let repository: RepositoryProtocol
    
    public init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    public func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity {
        return DustInfoEntity()
    }
    
    public func getDustInfo() -> [DustStoreEntity] {
        do {
            return try repository.getDustInfo()
        } catch {
            print("Load Error", error)
            return []
        }
    }
    
    public func deleteDustInfo(location: String) -> Bool {
        return true
    }
}
