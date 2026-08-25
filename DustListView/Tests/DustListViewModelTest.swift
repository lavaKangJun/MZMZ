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
import Common
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
        self.mockUsecase.registerWithThrows([DustStoreEntity].self, name: "getDustInfo") {
            return [DustStoreEntity(location: "강원도", longitude: "123.456", latitude: "456.789", isFavorite: false)]
        }
        self.mockUsecase.registerWithThrows(DustInfoEntity.self, name: "nearestStationDustInfo") {
            return DustInfoEntity(stationName: "강원도", pm10Value: 13, pm25Value: 24, dataTime: "2026-12-23", distanceKm: 0.4, sido: "강원도", addr: "대한민구 강원도")
        }
        
        // Act
        await viewModel.refresh()
        
        // Assert
        #expect(self.viewModel.dustListModels.first?.location == "강원도")
    }
    
    @Test("미세먼지 정보를 가져오는 실패 테스트")
    func fetchDustFailTest() async throws {
        // Arrange
        makeInit()
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
        await viewModel.refresh()
        
        // Assert
        #expect( self.viewModel.errorMessage == "데이터를 찾을 수 없습니다")
    }
    
    @Test("미세먼지 리스트 데이터 제거 테스트")
    func testDeleteDustListData() async throws {
        // Arrange
        makeInit()
        // 삭제 검증을 위한 데이터를 가져옴
        self.mockUsecase.registerWithThrows([DustStoreEntity].self, name: "getDustInfo") {
            return [DustStoreEntity(location: "강원도", longitude: "123.456", latitude: "456.789", isFavorite: false), DustStoreEntity(location: "서울", longitude: "789.456", latitude: "456.789", isFavorite: false)]
        }
        
        self.mockUsecase.register(Bool.self, name: "deleteDustInfo") {
            // ture: 삭제 성공
            return true
        }
        
        await self.viewModel.refresh()
        
        // Act
        self.viewModel.deleteLocation("강원도")
        
        // Assert
        #expect(self.viewModel.dustListModels.count == 1)
    }
    
    @Test("미세먼지 리스트 데이터 제거 실패 테스트")
    func testDeleteFailDustListData() async throws {
        // Arrange
        makeInit()
        // 삭제 검증을 위한 데이터를 가져옴
        self.mockUsecase.registerWithThrows([DustStoreEntity].self, name: "getDustInfo") {
            return [DustStoreEntity(location: "강원도", longitude: "123.456", latitude: "456.789", isFavorite: false), DustStoreEntity(location: "서울", longitude: "789.456", latitude: "456.789", isFavorite: false)]
        }
        
        self.mockUsecase.register(Bool.self, name: "deleteDustInfo") {
            // ture: 삭제 실패
            return false
        }
        
        await self.viewModel.refresh()
        
        // Act
        self.viewModel.deleteLocation("강원도")
        
        // Assert
        #expect(self.viewModel.dustListModels.count == 2)
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
        self.viewModel.routeToDetail(name: "강원도", station: "강원도", dustDensity: "12", microDustDensity: "6", dustGrade: .good, microDustGrade: .good, isFavorite: false)
        
        // Assert
        #expect(called == true, "routeToDetailView")
    }
}

class SpyRouting: DustListRouting, TestDouble {
    var scene: UIViewController?
    
    func routeToFindLocation() {
        self.verify(name: "routeToFindLocation", args: nil)
    }
    
    func routeToDetail(
        name: String,
        station: String?,
        dustDensity: String,
        microDustDensity: String,
        dustGrade: AirQualityGrade,
        microDustGrade: AirQualityGrade,
        isFavorite: Bool,
        dismiss: (() -> Void)?
    ) {
        self.verify(name: "routeToDetail", args: name)
    }
}
