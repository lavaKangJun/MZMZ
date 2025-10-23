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
    private let mockRepository: RepositoryProtocol
    private let mocekService: LocationServiceProtocol
    private let mockUsecase: DustListUseCaseProtocol
    private let viewModel: DustListViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var spyRouter: SpyRouting? {
        return self.viewModel.router as? SpyRouting
    }
    
    init() {
        mockRepository = MockingRepository(dataStore: FakeDataStore.shared)
        mocekService = MockingLocationService()
        mockUsecase = MockingDustListUseCase(repository: mockRepository, locationService: mocekService)
        viewModel = DustListViewModel(usecase: mockUsecase)
        viewModel.router = SpyRouting()
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
    
    @MainActor @Test("지역 찾는 뷰 라우팅 테스트")
    func testRouteToFindLocationView() {
        // Arrange
        var called = false
        self.spyRouter?.called(name: "routeToFindLocation") { _ in
            called = true
        }
        // Act
        self.viewModel.routeToFindLocation()
        
        // Assert
        #expect(called == true, "routeToFindLocationView")
    }
    
    @MainActor @Test("상세뷰로 라우팅 테스트")
    func testRouteToDetailView() {
        // Arrange
        var called = false
        self.spyRouter?.called(name: "routeToDetail") { location in
            if (location as? String) == "강원도" {
                called = true
            }
        }
        
        // Act
        self.viewModel.routeToDetail(name: "강원도", longitude: "123.456", latitude: "789.123")
        
        // Assert
        #expect(called == true, "routeToDetailView")
    }
}
