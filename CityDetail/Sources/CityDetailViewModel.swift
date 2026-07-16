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
    let tmX: Double?
    let tmY: Double?
    var isFavorite: Bool = false
    var dustGrade: AirQualityGrade = .checking
    var microDustGrade: AirQualityGrade = .checking
    
    init(location: String, entity: MesureDnstyEntity, tmX: Double?, tmY: Double?) {
        self.location = location
        self.station = entity.location
        self.dustDensity = entity.pm10Value
        self.microDustDensity = entity.pm25Value
        self.dustGrade = AirQualityGrade.grade(forPM10: dustDensity)
        self.microDustGrade = AirQualityGrade.grade(forPM25: microDustDensity)
        self.tmX = tmX
        self.tmY = tmY
    }
    
    init(
        location: String,
        station: String?,
        dustDensity: String,
        microDustDensity: String,
        isFavorite: Bool,
        dustGrade: AirQualityGrade,
        microDustGrade: AirQualityGrade
    ) {
        self.location = location
        self.station = station
        self.dustGrade = dustGrade
        self.microDustGrade = microDustGrade
        self.dustDensity = dustDensity
        self.microDustDensity = microDustDensity
        self.isFavorite = isFavorite
        self.tmX = nil
        self.tmY = nil
    }
    
    init(location: String) {
        self.location = location
        self.station = nil
        self.dustDensity = "-1"
        self.microDustDensity = "-1"
        self.dustGrade = AirQualityGrade.grade(forPM10: dustDensity)
        self.microDustGrade = AirQualityGrade.grade(forPM25: microDustDensity)
        self.tmX = nil
        self.tmY = nil
    }
}

@MainActor
public final class CityDetailViewModel: ObservableObject, @unchecked Sendable {
    private let usecase: DustInfoUseCaseProtocol
    public var router: CityDetailRouting?
    
    private let detailViewType: DetailViewType
    private var dismiss: (() -> Void)?
    @Published var dataModel: CityDetailViewDataModel
    @Published private(set) var loadState: LoadState = .loading
    
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
                microDustGrade: detailData.microDustGrade
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
                    let entity = LocationInfoEntity(latitude: searchData.latitude, longtitude: searchData.longitude)
                    let tmLocation = try await self.usecase.convertToTMCoordinate(location: entity)

                    guard
                        let tmX = tmLocation?.x,
                        let tmY = tmLocation?.y,
                        let dustInfo = try await self.usecase.fetchMesureDnsty(tmX: tmX, tmY: tmY) else {
                        let dataModel = CityDetailViewDataModel(location: searchData.location)
                        self.dataModel = dataModel
                        self.loadState = .failed
                        return
                    }
                    let dataModel = CityDetailViewDataModel(location: searchData.location, entity: dustInfo, tmX: tmX, tmY: tmY)
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
            self.usecase.saveDustInfo(location: searchData.location, longitude: searchData.longitude, latitude: searchData.latitude, tmX: self.dataModel.tmX ?? -1, tmY: self.dataModel.tmY ?? -1, isFavorite: false)
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
