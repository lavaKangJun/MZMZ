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
    public let tmX: Double?
    public let tmY: Double?
    public let isSearchResult: Bool
    public let dismiss: (() -> Void)?
    
    public init(
        name: String,
        station: String?,
        longitude: String,
        latitude: String,
        tmX: Double?,
        tmY: Double?,
        isSearchResult: Bool,
        dismiss: (() -> Void)?
    ) {
        self.name = name
        self.station = station
        self.longitude = longitude
        self.latitude = latitude
        self.tmX = tmX
        self.tmY = tmY
        self.isSearchResult = isSearchResult
        self.dismiss = dismiss
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
