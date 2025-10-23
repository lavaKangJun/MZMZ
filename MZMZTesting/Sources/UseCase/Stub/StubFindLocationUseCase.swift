//
//  StubFindLocationUseCase.swift
//  Testing
//
//  Created by 강준영 on 2025/05/11.
//

import Foundation
import Domain

public final class StubFindLocationUseCase: FindLocationUseCaseProtocol {
    private let repository: RepositoryProtocol
    
    public init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    public func findLocation(location: String) async throws -> [SearchLocationEntity] {
        return try await self.repository.findLocation(location: location, key: "authKey")
    }
}
