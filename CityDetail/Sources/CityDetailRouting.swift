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

public final class CityDetailRouter: CityDetailRouting {
    public var scene: UIViewController?
    
    public func dimisss() {
        self.scene?.dismiss(animated: false)
    }
    public func routeMainView() {
        // presentingViewController: 현재 위에 있는 부모 뷰컨트롤러
        guard let presentingVC = self.scene?.presentingViewController?.presentingViewController else { return }
        presentingVC.dismiss(animated: false)
    }
}
