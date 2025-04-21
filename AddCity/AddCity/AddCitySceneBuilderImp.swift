//
//  AddCitySceneBuilderImp.swift
//  AddCity
//
//  Created by 강준영 on 2025/04/21.
//

import UIKit
import SwiftUI
import Scene

public final class AddCitySceneBuilderImp: AddCitySceneBuilder {
    public init() { }
    
    public func makeAddCityScene() -> UIViewController {
        let addCityView = AddCityView()
        let viewControlelr = UIHostingController(rootView: addCityView)
        return viewControlelr
    }
}
