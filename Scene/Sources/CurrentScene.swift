//
//  Scene.swift
//  Scene
//
//  Created by 강준영 on 2025/04/21.
//

import UIKit
import SwiftUI
import Common

public enum DetailViewType {
    public struct SeachData {
        public let location: String
        public let longitude: String
        public let latitude: String
    }
    public struct DetailData {
        public let location: String
        public let station: String?
        public let dustDensity: String
        public let microDustDensity: String
        public let isFavorite: Bool
        public let dustGrade: AirQualityGrade
        public let microDustGrade: AirQualityGrade
    }
    case search(SeachData)
    case deatail(DetailData)
}

public struct CityDetailDependency {
    public let detailViewType: DetailViewType
    public let dismiss: (() -> Void)?
    
    // 미세먼지 디테일
    public init(
        name: String,
        station: String?,
        dustDensity: String,
        microDustDensity: String,
        dustGrade: AirQualityGrade,
        microDustGrade: AirQualityGrade,
        isFavorite: Bool,
        dismiss: (() -> Void)?
    ) {
        self.detailViewType = 
            .deatail(
                DetailViewType.DetailData(
                    location: name,
                    station: station,
                    dustDensity: dustDensity,
                    microDustDensity: microDustDensity,
                    isFavorite: isFavorite,
                    dustGrade: dustGrade,
                    microDustGrade: microDustGrade
                )
            )
        self.dismiss = dismiss
    }
    
    // 검색 결과
    public init(
        name: String,
        longitude: String,
        latitude: String
    ) {
        self.detailViewType = .search(
            DetailViewType.SeachData(
                location: name,
                longitude: longitude,
                latitude: latitude
            )
        )
        self.dismiss = nil
    }
}

public protocol CityDetailSceneBuilder {
    func makeCityDetailScene(_ dependency: CityDetailDependency) -> UIViewController
}

public protocol AddCitySceneBuilder {
    func makeAddCityScene() -> UIViewController
}

public protocol DustListSceneBuilder {
    func makeDustListScene() -> UIViewController
}

public protocol CurrentScene: UIViewController { }
