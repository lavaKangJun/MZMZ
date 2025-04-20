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
}

public final class DustListRouter: DustListRouting {
    public var scene: UIViewController?
    public let addCitySceneBuilder: AddCitySceneBuilder
    
    public init(addCitySceneBuilder: AddCitySceneBuilder) {
        self.addCitySceneBuilder = addCitySceneBuilder
    }
    
    public func routeToFindLocation() {
        scene?.present(addCitySceneBuilder.makeAddCityScene(), animated: true)
    }
}
