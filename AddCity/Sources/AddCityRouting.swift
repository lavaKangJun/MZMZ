//
//  AddCityRouting.swift
//  AddCity
//
//  Created by 강준영 on 2025/05/01.
//

import UIKit
import Scene

public protocol AddCityRouting {
    var scene: UIViewController? { get set }
    func routeToCityDetail(dependency: CityDetailDependency)
    func dismiss()
}

public final class AddCityRouter: AddCityRouting {
    public var scene: UIViewController?
    public let detailCitySceneBuilder: CityDetailSceneBuilder
    
    init(detailCitySceneBuilder: CityDetailSceneBuilder) {
        self.detailCitySceneBuilder = detailCitySceneBuilder
    }
    
    public func routeToCityDetail(dependency: CityDetailDependency) {
        scene?.present(self.detailCitySceneBuilder.makeCityDetailScene(dependency), animated: false)
    }
    
    public func dismiss() {
        scene?.dismiss(animated: false)
    }
}
