//
//  AppDelegate.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/08.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var applicationViewModel: ApplicationRootViewModel!
    weak var applicationRouter: ApplicationRouter?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let builder = ApplicationRootBuilder()
        self.applicationViewModel = builder.makeRootViewModel()
        self.applicationRouter = self.applicationViewModel.router
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.applicationRouter?.window = window
        self.applicationViewModel.prepareInitialScene()
        return true
    }
}

