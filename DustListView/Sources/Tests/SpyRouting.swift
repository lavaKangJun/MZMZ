//
//  SpyRouting.swift
//  DustListView
//
//  Created by 강준영 on 10/23/25.
//  Copyright © 2025 Junyoung. All rights reserved.
//
import UIKit
import MZMZTesting

class SpyRouting: DustListRouting, TestDouble {
    var scene: UIViewController?
    
    func routeToFindLocation() {
        self.verify(name: "routeToFindLocation", args: nil)
    }
    
    func routeToDetail(name: String, longitude: String, latitude: String) {
        self.verify(name: "routeToDetail", args: name)
    }
}
