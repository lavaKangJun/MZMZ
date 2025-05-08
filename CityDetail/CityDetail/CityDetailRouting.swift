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
}

public final class CityDetailRouter: CityDetailRouting {
    public var scene: UIViewController?
    
    public func dimisss() {
        self.scene?.dismiss(animated: false)
    }
}
