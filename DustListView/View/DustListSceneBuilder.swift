//
//  DustListSceneBuilder.swift
//  DustListView
//
//  Created by 강준영 on 2025/04/21.
//

import UIKit
import SwiftUI
import Domain
import Scene
import Testing
import Repository
import Scene

public final class DustListSceneBuilderImp: DustListSceneBuilder {
    private let addCitySceneBuilder: AddCitySceneBuilder
    
    public init(addCitySceneBuilder: AddCitySceneBuilder) {
        self.addCitySceneBuilder = addCitySceneBuilder
    }
    
    public func makeDustListScene() -> UIViewController {
        let isTesting = true
        if isTesting {
            let repository = MockingRepository()
            let locationService = MockingLocationService()
            let useCase = MockingDustListUseCase(repository: repository, locationService: locationService)
            let router = DustListRouter(addCitySceneBuilder: self.addCitySceneBuilder)
            let viewModel = DustListViewModel(repository: repository, locationService: locationService, usecase: useCase)
            let listView = DustListView(viewModel: viewModel)
            let viewControlelr = UIHostingController(rootView: listView)
            router.scene = viewControlelr
            
            viewModel.router = router
            return viewControlelr
        } else {
            let repository = Repository(remote: Remote())
            let locationService = LocationService()
            let useCase = DustListUseCase(repository: repository, locationService: locationService)
            let router = DustListRouter(addCitySceneBuilder: self.addCitySceneBuilder)
            let viewModel = DustListViewModel(repository: repository, locationService: locationService, usecase: useCase)
            let listView = DustListView(viewModel: viewModel)
            let viewControlelr = UIHostingController(rootView: listView)
            router.scene = viewControlelr
            return viewControlelr
        }
    }
}
