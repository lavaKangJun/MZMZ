//
//  Scene.swift
//  Scene
//
//  Created by 강준영 on 2025/04/21.
//

import UIKit
import SwiftUI

public struct CityDetailDependency {
    public let name: String
    public let station: String?
    public let longitude: String
    public let latitude: String
    public let isSearchResult: Bool
    public init(
        name: String,
        station: String?,
        longitude: String,
        latitude: String,
        isSearchResult: Bool
    ) {
        self.name = name
        self.station = station
        self.longitude = longitude
        self.latitude = latitude
        self.isSearchResult = isSearchResult
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
