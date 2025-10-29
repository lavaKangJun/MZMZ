//
//  CityDetailRouting.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/08.
//

import UIKit

public protocol CityDetailRouting {
    var scene: UIViewController? { get set }
    func dimisss()
    func routeMainView()
}

public final class CityDetailRouter: @preconcurrency CityDetailRouting {
    public var scene: UIViewController?
    
    @MainActor public func dimisss() {
        self.scene?.dismiss(animated: false)
    }
    @MainActor public func routeMainView() {
        // presentingViewController: 현재 위에 있는 부모 뷰컨트롤러
        guard let presentingVC = self.scene?.presentingViewController?.presentingViewController else { return }
        presentingVC.dismiss(animated: false)
    }
}
