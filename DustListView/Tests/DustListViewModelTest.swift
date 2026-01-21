//
//  DustListViewModelTest.swift
//  DustListView
//
//  Created by 강준영 on 10/21/25.
//  Copyright © 2025 Junyoung. All rights reserved.
//
import UIKit
import Testing
import Combine
import Repository
import Domain
import MZMZTesting

@testable import DustListView

// Suite: 테스트 그룹화 함
@Suite("DustListViewModel Tests")
class DustListViewModelTests {
    private var mockUsecase: MockDustListUseCase
    private var viewModel: DustListViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var spyRouter: SpyRouting? {
        return self.viewModel.router as? SpyRouting
    }
    
    init() {
        mockUsecase = MockDustListUseCase()
        viewModel = DustListViewModel(usecase: mockUsecase)
        viewModel.router = SpyRouting()
    }
    
    func makeInit() {
        mockUsecase = MockDustListUseCase()
        viewModel = DustListViewModel(usecase: mockUsecase)
        viewModel.router = SpyRouting()
    }
    
    // struct라 teardown같은 코드는 필요없음
    
    @Test("미세먼지 정보를 가져오는 테스트")
    func fetchDustTest() async throws {
        // Arrange
        makeInit()
        var dustList: [DustListViewDataModel] = []
        
        self.mockUsecase.registerWithThrows([DustStoreEntity].self, name: "getDustInfo") {
            return [DustStoreEntity(location: "강원도", longitude: "123.456", latitude: "456.789")]
        }
        
        // Act
        self.viewModel.dustListStream
            .dropFirst()
            .sink { result in
                dustList = result
            }.store(in: &cancellables)
        
        viewModel.fetchDust()
        
        try await Task.sleep(for: .seconds(0.3))
        
        // Assert
        #expect(dustList.first?.location == "강원도", "list: \(dustList.count)")
    }
    
    @Test("미세먼지 정보를 가져오는 실패 테스트")
    func fetchDustFailTest() async throws {
        // Arrange
        makeInit()
        var errorMsg = ""
        self.mockUsecase.registerWithThrows([DustStoreEntity].self, name: "getDustInfo") {
            let error = NSError(
                domain: "com.mzmz.dustlist",
                code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey: "데이터를 찾을 수 없습니다"
                ]
            )
            
            throw error
        }
        
        // Act
        self.viewModel.errorStream
            .sink { error in
                errorMsg = error
            }.store(in: &cancellables)
        
        viewModel.fetchDust()
        
        try await Task.sleep(for: .seconds(0.3))
        
        // Assert
        #expect(errorMsg == "데이터를 찾을 수 없습니다")
    }
    
    @Test("미세먼지 리스트 데이터 제거 테스트")
    func testDeleteDustListData() async throws {
        // Arrange
        makeInit()
        var dataListCount = 0
        
        // 삭제 검증을 위한 데이터를 가져옴
        self.mockUsecase.registerWithThrows([DustStoreEntity].self, name: "getDustInfo") {
            return [DustStoreEntity(location: "강원도", longitude: "123.456", latitude: "456.789"), DustStoreEntity(location: "서울", longitude: "789.456", latitude: "456.789")]
        }
        
        self.mockUsecase.register(Bool.self, name: "deleteDustInfo") {
            // ture: 삭제 성공
            return true
        }
        
        self.viewModel.fetchDust()
        try await Task.sleep(for: .seconds(0.3))
        
        // Act
        self.viewModel.dustListStream
            .print("dustListStream")
            .sink { result in
                // 삭제 후 스트림에도 반영됨
                dataListCount = result.count
                
            }.store(in: &cancellables)
        
        self.viewModel.deleteLocation("강원도")
        try await Task.sleep(for: .seconds(0.3))
        
        // Assert
        #expect(dataListCount == 1, "삭제 실패, \(dataListCount)")
    }
    
    @Test("미세먼지 리스트 데이터 제거 실패 테스트")
    func testDeleteFailDustListData() async throws {
        // Arrange
        makeInit()
        var dataListCount = 0
        
        // 삭제 검증을 위한 데이터를 가져옴
        self.mockUsecase.registerWithThrows([DustStoreEntity].self, name: "getDustInfo") {
            return [DustStoreEntity(location: "강원도", longitude: "123.456", latitude: "456.789"), DustStoreEntity(location: "서울", longitude: "789.456", latitude: "456.789")]
        }
        
        self.mockUsecase.register(Bool.self, name: "deleteDustInfo") {
            // ture: 삭제 실패
            return false
        }
        
        self.viewModel.fetchDust()
        
        // Act
        self.viewModel.dustListStream
            .sink { result in
                // 삭제 실패 후 스트림에 영향 없음
                dataListCount = result.count
            }.store(in: &cancellables)
        
        self.viewModel.deleteLocation("강원도")
        try await Task.sleep(for: .seconds(0.3))
        
        // Assert
        #expect(dataListCount == 2, "삭제 실패, \(dataListCount)")
    }
    
    @MainActor @Test("지역 찾는 뷰 라우팅 테스트")
    func testRouteToFindLocationView() {
        // Arrange
        makeInit()
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
        makeInit()
        var called = false
        self.spyRouter?.called(name: "routeToDetail") { location in
            if (location as? String) == "강원도" {
                called = true
            }
        }
        
        // Act
        self.viewModel.routeToDetail(name: "강원도", station: "강원도",  longitude: "123.456", latitude: "789.123")
        
        // Assert
        #expect(called == true, "routeToDetailView")
    }
}

class SpyRouting: DustListRouting, TestDouble {
    var scene: UIViewController?
    
    func routeToFindLocation() {
        self.verify(name: "routeToFindLocation", args: nil)
    }
    
    func routeToDetail(name: String, station: String?, longitude: String, latitude: String) {
        self.verify(name: "routeToDetail", args: name)
    }
}
