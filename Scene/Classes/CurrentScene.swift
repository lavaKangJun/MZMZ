//
//  Scene.swift
//  Scene
//
//  Created by 강준영 on 2025/04/21.
//

import UIKit
import SwiftUI

public protocol AddCitySceneBuilder {
    func makeAddCityScene() -> UIViewController
}

public protocol DustListSceneBuilder {
    func makeDustListScene() -> UIViewController
}

public protocol CurrentScene: UIViewController { }
