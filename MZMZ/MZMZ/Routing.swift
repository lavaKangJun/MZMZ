//
//  Routing.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/08.
//

import UIKit
import Scene
import DustListView
import AddCity

public protocol Routing {
    func showError()
    func showToast()
    func closeScene()
}

protocol ApplicationRouting: Routing {
    func setupInitScene()
}

final class ApplicationRouter: ApplicationRouting, @unchecked Sendable {
    var window: UIWindow!
    
    // TODO
    func showError() { }
    func showToast() { }
    func closeScene() { }
    
    func setupInitScene() { 
        let builder = MainSceneBuilder(dustListSceneBuilder: self.dustListSceneBuilder())
        
        self.window.rootViewController = builder.makeMainScene()
        self.window.makeKeyAndVisible()
    }
    
    private func dustListSceneBuilder() -> DustListSceneBuilder {
        return DustListSceneBuilderImp(addCitySceneBuilder: self.addCitySceneBuilder())
    }
    
    private func addCitySceneBuilder() -> AddCitySceneBuilder {
        return AddCitySceneBuilderImp()
    }
}
