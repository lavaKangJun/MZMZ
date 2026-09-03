//
//  CityDetailViewModel.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import Foundation
import Domain
import SwiftUI
import WidgetKit
import Common
import Scene
import Repository

enum LoadState {
    case loading
    case loaded
    case failed
}

public struct CityDetailViewDataModel {
    let location: String
    let station: String?
    let dustDensity: String
    let microDustDensity: String
    var isFavorite: Bool = false
    var dustGrade: AirQualityGrade = .checking
    var microDustGrade: AirQualityGrade = .checking
    /// 측정 시각. 서버가 주는 "yyyy-MM-dd HH:mm"(KST) 원문. 없으면 nil.
    var dataTime: String? = nil
    
    init(location: String, entity: DustInfoEntity) {
        self.location = location
        self.station = entity.stationName
        // Int? 를 그대로 보간하면 "Optional(13)" 이 되어 grade(forPM10:) 의
        // Int(_:) 파싱이 실패하고 값이 있는데도 점검중으로 표시된다.
        self.dustDensity = "\(entity.pm10Value ?? -1)"
        self.microDustDensity = "\(entity.pm25Value ?? -1)"
        self.dustGrade = AirQualityGrade.grade(forPM10: dustDensity)
        self.microDustGrade = AirQualityGrade.grade(forPM25: microDustDensity)
        self.dataTime = entity.dataTime
    }
    
    init(
        location: String,
        station: String?,
        dustDensity: String,
        microDustDensity: String,
        isFavorite: Bool,
        dustGrade: AirQualityGrade,
        microDustGrade: AirQualityGrade,
        dataTime: String?
    ) {
        self.location = location
        self.station = station
        self.dustGrade = dustGrade
        self.microDustGrade = microDustGrade
        self.dustDensity = dustDensity
        self.microDustDensity = microDustDensity
        self.isFavorite = isFavorite
        self.dataTime = dataTime
    }
    
    init(location: String) {
        self.location = location
        self.station = nil
        self.dustDensity = "-1"
        self.microDustDensity = "-1"
        self.dustGrade = AirQualityGrade.grade(forPM10: dustDensity)
        self.microDustGrade = AirQualityGrade.grade(forPM25: microDustDensity)
    }
}

@MainActor
@Observable
public final class CityDetailViewModel: @unchecked Sendable {
    private let usecase: DustInfoUseCaseProtocol
    @ObservationIgnored public var router: CityDetailRouting?
    
    private let detailViewType: DetailViewType
    private var dismiss: (() -> Void)?
    var dataModel: CityDetailViewDataModel
    private(set) var loadState: LoadState = .loading
    
    init(
        detailViewType: DetailViewType,
        dismiss: (() -> Void)?,
        usecase: DustInfoUseCaseProtocol
    ) {
        self.detailViewType = detailViewType
        self.dismiss = dismiss
        self.usecase = usecase
        switch self.detailViewType {
        case .search(let searchData):
            self.dataModel = CityDetailViewDataModel(location: searchData.location)
            fetchCurrentCityDustInfo()
        case .deatail(let detailData):
            self.dataModel = CityDetailViewDataModel(
                location: detailData.location,
                station: detailData.station,
                dustDensity: detailData.dustDensity,
                microDustDensity: detailData.microDustDensity,
                isFavorite: detailData.isFavorite,
                dustGrade: detailData.dustGrade,
                microDustGrade: detailData.microDustGrade,
                dataTime: detailData.dataTime
            )
            self.loadState = .loaded
        }
    }
    
    var isSearched: Bool {
        switch self.detailViewType {
        case .search:
            return true
        case .deatail:
            return false
        }
    }
    
    private func fetchCurrentCityDustInfo() {
        switch self.detailViewType {
        case let .search(searchData):
            Task {
                do {
                    let dustInfo = try await self.usecase.nearestStationDustInfo(lat: searchData.latitude, lng: searchData.longitude)
                    let dataModel = CityDetailViewDataModel(location: searchData.location, entity: dustInfo)
                    self.dataModel = dataModel
                    self.loadState = .loaded
                                                                                 
                } catch {
                    self.dataModel = CityDetailViewDataModel(location: searchData.location)
                    self.loadState = .failed
                }
            }
        default:
            return
        }
    }
    
    // 검색을 통해 들어온 경우 '추가' 버튼을 통해 지역 저정
    func saveCity() {
        if case let .search(searchData) = self.detailViewType {
            self.usecase.saveDustInfo(location: searchData.location, longitude: searchData.longitude, latitude: searchData.latitude, isFavorite: false)
            self.router?.routeMainView()
        }
    }
    
    func cancel() {
        self.router?.dimisss()
    }
    
    func disappear() {
        self.dismiss?()
    }
    
    func toggleFavorite() {
        let currentDataModel = self.dataModel
        let currentFavorite = currentDataModel.isFavorite
        do {
            try usecase.updateFavorite(location: currentDataModel.location, isFavorite: !currentFavorite)
            var updatedDataModel = currentDataModel
            updatedDataModel.isFavorite = !currentFavorite
            self.dataModel = updatedDataModel
            WidgetCenter.shared.reloadTimelines(ofKind: "MZMZWidzet")
        } catch let error {
            // error 알럿 추가 필요
            if case SQLiteError.overLike = error {
                self.router?.errorAlert()
            }
            
            print("즐겨찾기 업데이트 실패: \(error)")
        }
    }
}
