//
//  FindLocationUseCase.swift
//  Domain
//
//  Created by 강준영 on 2025/04/23.
//

import Foundation

public protocol FindLocationUseCaseProtocol {
    func findLocation(location: String) async throws -> [SearchLocationEntity]
}

public final class FindLocationUseCase: FindLocationUseCaseProtocol {
    private let repository: RepositoryProtocol
    private let authKey = "16f1ed764daa4d2c4d6e3f0d25269ca5"
    
    public init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    public func findLocation(location: String) async throws -> [SearchLocationEntity] {
        return try await repository.findLocation(location: location, key: authKey)
    }
}
