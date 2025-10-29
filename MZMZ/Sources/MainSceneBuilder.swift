//
//  MainSceneBuilder.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/08.
//

import UIKit
import Domain
import Repository
import SwiftUI
import MZMZTesting
//import DustListView
import AddCity
import Scene

final class MainSceneBuilder {
    private let dustListSceneBuilder: DustListSceneBuilder
    
    init(dustListSceneBuilder: DustListSceneBuilder) {
        self.dustListSceneBuilder = dustListSceneBuilder
    }
    
    func makeMainScene() -> UIViewController {
        return self.dustListSceneBuilder.makeDustListScene()
    }
}
