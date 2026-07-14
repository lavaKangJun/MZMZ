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

@MainActor
public final class CityDetailViewModel: ObservableObject, @unchecked Sendable {
    private let name: String
    private let station: String?
    private let longitude: String
    private let latitude: String
    private let tmX: Double
    private let tmY: Double
    private let isSearchResult: Bool
    private let usecase: DustInfoUseCaseProtocol
    public var router: CityDetailRouting?
    private var dismiss: (() -> Void)?
    @Published var dataModel: CityDetailViewDataModel
    @Published private(set) var loadState: LoadState = .loading
    
    init(
        name: String,
        station: String?,
        longitude: String,
        latitude: String,
        tmX: Double,
        tmY: Double,
        isSearchResult: Bool,
        dismiss: (() -> Void)?,
        usecase: DustInfoUseCaseProtocol
    ) {
        self.name = name
        self.station = station
        self.longitude = longitude
        self.latitude = latitude
        self.tmX = tmX
        self.tmY = tmY
        self.isSearchResult = isSearchResult
        self.dismiss = dismiss
        self.usecase = usecase
        self.dataModel = CityDetailViewDataModel(location: name)
        fetchCurrentCityDustInfo()
    }
    
    var isSearched: Bool {
        return self.isSearchResult
    }
    
    func fetchCurrentCityDustInfo() {
        Task {
            do {
                // 즐겨찾기 상태 조회
                let tf = Date()
                let isFavorite = (try? self.usecase.getFavoriteStatus(location: self.name)) ?? false
                guard let dustInfo = try await self.usecase.fetchMesureDnsty(tmX: tmX, tmY: tmY) else {
        
                        let dataModel = CityDetailViewDataModel(location: self.name)
                        self.dataModel = dataModel
                        self.loadState = .failed
                    
                    return
                }
                let tA = Date()
                    let dataModel = CityDetailViewDataModel(location: self.name, entity: dustInfo, isFavorite: isFavorite)
                    self.dataModel = dataModel
                    self.loadState = .loaded
            } catch {
                    self.dataModel = CityDetailViewDataModel(location: self.name)
                    self.loadState = .failed
                
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
