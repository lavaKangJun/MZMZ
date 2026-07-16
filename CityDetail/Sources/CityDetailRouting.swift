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
    func errorAlert()
}

@MainActor
public final class CityDetailRouter: @preconcurrency CityDetailRouting {
    public weak var scene: UIViewController?
    
    public func dimisss() {
        //        self.scene?.dismiss(animated: false)
        guard let presentingVC = self.scene?.presentingViewController?.presentingViewController else { return }
        presentingVC.dismiss(animated: false)
    }
    public func routeMainView() {
        // presentingViewController: 현재 위에 있는 부모 뷰컨트롤러
        guard let presentingVC = self.scene?.presentingViewController?.presentingViewController else { return }
        presentingVC.dismiss(animated: false)
    }
    
    public func errorAlert() {
        let alert = UIAlertController(title: nil, message: "즐겨찾기는 2개만 가능합니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        self.scene?.present(alert, animated: true, completion: nil)
    }
    
}
