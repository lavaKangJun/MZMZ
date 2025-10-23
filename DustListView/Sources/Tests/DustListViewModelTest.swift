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
        mockRepository = StubRepository(dataStore: FakeDataStore.shared)
        mocekService = StubLocationService()
        mockUsecase = StubDustListUseCase(repository: mockRepository, locationService: mocekService)
        viewModel = DustListViewModel(usecase: mockUsecase)
        viewModel.router = SpyRouting()
    }
    
    // struct라 teardown같은 코드는 필요없음
    
    // Mocking으로 다시만들어야함 내가 만든건 mock이 아니라 fake임
// 근데 UI작업할 때는 fake가 필요하긴함... 기존 객체를 fake로 만들고 mock을 하나 더 만들어야 할듯?
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
