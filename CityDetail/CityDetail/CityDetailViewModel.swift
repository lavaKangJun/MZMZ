//
//  CityDetailViewModel.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import Foundation
import Domain
import SwiftUI

public struct CityDetailViewDataModel {
    let location: String
    let dustDensity: String
    let microDustDensity: String
    
    init(location: String, entity: MesureDnstyEntity) {
        self.location = location
        self.dustDensity = entity.pm10Value
        self.microDustDensity = entity.pm25Value
    }
    
    var dustGradeText: String {
        guard let gradeValue = Int(dustDensity) else { return "" }
        if 0...30 ~= gradeValue {
            return "좋음"
        } else if 31...80 ~= gradeValue {
            return "보통"
        } else if 81...150 ~= gradeValue {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
        
    }
    
    var microDustGradeText: String {
        guard let gradeValue = Int(microDustDensity) else { return "" }
        if 0...15 ~= gradeValue {
            return "좋음"
        } else if 16...50 ~= gradeValue {
            return "보통"
        } else if 51...100 ~= gradeValue {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
    }
    
    var backgroundColor: [Color] {
        guard let gradeValue = Int(dustDensity) else { return [Color.clear] }
        if 0...30 ~= gradeValue {
            return [Color.blue.opacity(0.5)]
        } else if 31...80 ~= gradeValue {
            return [Color.blue.opacity(0.5), Color.black.opacity(0.1)]
        } else if 81...150 ~= gradeValue {
            return [Color.blue.opacity(0.5), Color.black.opacity(0.5)]
        } else {
            return [Color.blue.opacity(0.3), Color.black.opacity(0.8)]
        }
    }
}

public final class CityDetailViewModel: ObservableObject {
    private let name: String
    private let longitude: String
    private let latitude: String
    private let isSearchResult: Bool
    private let usecase: DustInfoUseCaseProtocol
    public var router: CityDetailRouting?
    
    @Published var dataModel: CityDetailViewDataModel?
        
    init(
        name: String,
        longitude: String,
        latitude: String,
        isSearchResult: Bool,
        usecase: DustInfoUseCaseProtocol
    ) {
        self.name = name
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
            guard let latitude = Double(self.latitude),
                  let longtitude = Double(self.longitude)
            else {
                return
            }
            let entity = LocationInfoEntity(latitude: latitude, longtitude: longtitude)
            let tmLocation = try await self.usecase.convertToTMCoordinate(location: entity)
            
            guard let tmX = tmLocation?.x, let tmY = tmLocation?.y else { return }
            guard let dustInfo = try await self.usecase.fetchMesureDnsty(tmX: tmX, tmY: tmY) else { return }
            
            await MainActor.run {
                self.dataModel = CityDetailViewDataModel(location: self.name, entity: dustInfo)
            }
        }
    }
    
    // 검색을 통해 들어온 경우 '추가' 버튼을 통해 지역 저정
    func saveCity() {
        self.usecase.saveDustInfo(location: self.name, longitude: self.longitude, latitude: self.latitude)
        self.router?.routeMainView()
    }
    
    func cancel() {
        self.router?.dimisss()
    }
}
