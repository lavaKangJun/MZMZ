//
//  DustListUseCase.swift
//  Domain
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation

public protocol DustListUseCaseProtocol {
    func fetchDust() -> [DustEntity]
}

public final class  DustListUseCase: DustListUseCaseProtocol {
    private let repository: RepositoryProtocol
    
    public init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    public func fetchDust() -> [DustEntity] {
        return repository.fetchDust()
    }
}
