//
//  DustListViewModelTest.swift
//  DustListView
//
//  Created by 강준영 on 10/21/25.
//  Copyright © 2025 Junyoung. All rights reserved.
//
import Foundation
import Testing
import Combine
import Repository
import Domain
import MZMZTesting

@testable import DustListView

// Suite: 테스트 그룹화 함
@Suite("DustListViewModel Tests")
struct DustListViewModelTests {
    let mockRepository: RepositoryProtocol
    let mocekService: LocationServiceProtocol
    let mockUsecase: DustListUseCaseProtocol
    let viewModel: DustListViewModel
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        mockRepository = MockingRepository(dataStore: FakeDataStore.shared)
        mocekService = MockingLocationService()
        mockUsecase = MockingDustListUseCase(repository: mockRepository, locationService: mocekService)
        viewModel = DustListViewModel(usecase: mockUsecase)
    }
    
    // struct라 teardown같은 코드는 필요없음
    
    @Test("미세먼지 정보를 가져오는 테스트")
    mutating func fetchDustTest() async throws {
        // Arrange
        // Act
        self.viewModel.dustListStream
            .dropFirst()
            .sink { result in
                // Assert
                #expect(result.count > 0, "list: \(result)")
            }.store(in: &cancellables)
        
        viewModel.fetchDust()
    }
//
//    private func waitActionResult<T>(from publisher: AnyPublisher<T, Never>) async throws -> T {
//        try await withCheckedThrowingContinuation { continuation in
//            var cancellable: AnyCancellable?
//            cancellable = publisher
//                .setFailureType(to: Error.self)
//                .timeout(.seconds(3), scheduler: DispatchQueue.main, options: nil, customError:nil)
//                .sink(receiveCompletion: { completion in
//                    if case let .failure(error) = completion {
//                        continuation.resume(throwing: error)
//                    }
//                }, receiveValue: { value in
//                    nonisolated(unsafe) let result = value
//                    continuation.resume(returning: result)
//                    cancellable?.cancel()
//                })
//        }
//    }
}

