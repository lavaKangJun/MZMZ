//
//  Routing.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/08.
//

import UIKit

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
        let builder = MainSceneBuilder()
        
        self.window.rootViewController = builder.makeMainScene()
        self.window.makeKeyAndVisible()
    }
}
