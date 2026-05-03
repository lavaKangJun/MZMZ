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

public struct CityDetailViewDataModel {
    let location: String
    let station: String?
    let dustDensity: String
    let microDustDensity: String
    var isFavorite: Bool = false
    var dustGrade: AirQualityGrade = .checking
    var microDustGrade: AirQualityGrade = .checking
    
    init(location: String, entity: MesureDnstyEntity, isFavorite: Bool) {
        self.location = location
        self.station = entity.location
        self.dustDensity = entity.pm10Value
        self.microDustDensity = entity.pm25Value
        self.isFavorite = isFavorite
        self.dustGrade = AirQualityGrade.grade(forPM10: dustDensity)
        self.microDustGrade = AirQualityGrade.grade(forPM10: microDustDensity)
    }
    
    init(location: String) {
        self.location = location
        self.station = nil
        self.dustDensity = "-1"
        self.microDustDensity = "-1"
        self.dustGrade = AirQualityGrade.grade(forPM10: dustDensity)
        self.microDustGrade = AirQualityGrade.grade(forPM10: microDustDensity)
    }
}

public final class CityDetailViewModel: ObservableObject, @unchecked Sendable {
    private let name: String
    private let station: String?
    private let longitude: String
    private let latitude: String
    private let isSearchResult: Bool
    private let usecase: DustInfoUseCaseProtocol
    public var router: CityDetailRouting?
    
    @Published var dataModel: CityDetailViewDataModel?
        
    init(
        name: String,
        station: String?,
        longitude: String,
        latitude: String,
        isSearchResult: Bool,
        usecase: DustInfoUseCaseProtocol
    ) {
        self.name = name
        self.station = station
        self.longitude = longitude
        self.latitude = latitude
        self.isSearchResult = isSearchResult
        self.usecase = usecase
    }

    var isSearched: Bool {
        return self.isSearchResult
    }
    
    func fetchCurrentCityDustInfo() {
        Task {
            let entity = LocationInfoEntity(latitude: self.latitude, longtitude: self.longitude)
            let tmLocation = try await self.usecase.convertToTMCoordinate(location: entity)
            
            // 즐겨찾기 상태 조회
            let isFavorite = (try? self.usecase.getFavoriteStatus(location: self.name)) ?? false
            guard let tmX = tmLocation?.x, let tmY = tmLocation?.y else { return }
            guard let dustInfo = try await self.usecase.fetchMesureDnsty(tmX: tmX, tmY: tmY) else {
                await MainActor.run {
                    var dataModel = CityDetailViewDataModel(location: self.name)
                    self.dataModel = dataModel
                }
                return
            }
            
            await MainActor.run {
                var dataModel = CityDetailViewDataModel(location: self.name, entity: dustInfo, isFavorite: isFavorite)
                self.dataModel = dataModel
            }
        }
    }
    
    // 검색을 통해 들어온 경우 '추가' 버튼을 통해 지역 저정
    func saveCity() {
        self.usecase.saveDustInfo(location: self.name, longitude: self.longitude, latitude: self.latitude, isFavorite: false)
        self.router?.routeMainView()
    }
    
    func cancel() {
        self.router?.dimisss()
    }
    
    func toggleFavorite() {
        guard let currentDataModel = self.dataModel else {
            return
        }
        let currentFavorite = currentDataModel.isFavorite
        do {
            try usecase.updateFavorite(location: currentDataModel.location, isFavorite: !currentFavorite)
            
            // 새로운 dataModel 생성하여 업데이트
            var updatedDataModel = currentDataModel
            updatedDataModel.isFavorite = !currentFavorite
            self.dataModel = updatedDataModel
            WidgetCenter.shared.reloadTimelines(ofKind: "MZMZWidzet")
        } catch {
            // error 알럿 추가 필요
            print("즐겨찾기 업데이트 실패: \(error)")
        }
    }
}
