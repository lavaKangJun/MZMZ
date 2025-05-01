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
    public let longitude: String
    public let latitude: String
    
    public init(name: String, longitude: String, latitude: String) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
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
