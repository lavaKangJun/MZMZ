//
//  DustListRouting.swift
//  DustListView
//
//  Created by 강준영 on 2025/04/21.
//

import UIKit
import Scene

public protocol DustListRouting {
    var scene: UIViewController? { get set}
    func routeToFindLocation()
    func routeToDetail(name: String, longitude: String, latitude: String)
}

public final class DustListRouter: DustListRouting {
    public var scene: UIViewController?
    public let addCitySceneBuilder: AddCitySceneBuilder
    public let cityDetailSceneBuilder: CityDetailSceneBuilder
    
    public init(addCitySceneBuilder: AddCitySceneBuilder, cityDetailSceneBuilder: CityDetailSceneBuilder) {
        self.addCitySceneBuilder = addCitySceneBuilder
        self.cityDetailSceneBuilder = cityDetailSceneBuilder
    }
    
    public func routeToFindLocation() {
        let view = addCitySceneBuilder.makeAddCityScene()
        view.modalPresentationStyle = .fullScreen
        scene?.present(view, animated: true)
    }
    
    public func routeToDetail(name: String, longitude: String, latitude: String) {
        let dependency = CityDetailDependency(name: name, longitude: longitude, latitude: latitude, isSearchResult: false)
        let view = cityDetailSceneBuilder.makeCityDetailScene(dependency)
        scene?.present(view, animated: true)
    }
}
