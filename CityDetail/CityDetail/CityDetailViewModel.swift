//
//  CityDetailViewModel.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import Foundation
import Domain

public struct CityDetailViewDataModel {
    let location: String
    let dustDensity: String
    let dustGrade: String?
    let microDustDensity: String
    let microDustGrade: String?
    
    var dustGradeText: String {
        guard let dustGrade, let gradeValue = Int(dustGrade) else { return "" }
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
        guard let microDustGrade, let gradeValue = Int(microDustGrade) else { return "" }
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
    
    init(location: String, entity: MesureDnstyEntity) {
        self.location = location
        self.dustDensity = entity.pm10Value
        self.dustGrade = entity.pm10Grade
        self.microDustDensity = entity.pm25Value
        self.microDustGrade = entity.pm25Grade
    }
}

public final class CityDetailViewModel: ObservableObject {
    private let name: String
    private let longitude: String
    private let latitude: String
    private let isSearchResult: Bool
    private let usecase: DustInfoUseCaseProtocol
    
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
            
            self.dataModel = CityDetailViewDataModel(location: self.name, entity: dustInfo)
   
        }
    }
    
    // 검색을 통해 들어온 경우 '추가' 버튼을 통해 지역 저정
    func saveCity() {
        
    }
}
