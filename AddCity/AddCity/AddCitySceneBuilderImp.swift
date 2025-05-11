//
//  AddCitySceneBuilderImp.swift
//  AddCity
//
//  Created by 강준영 on 2025/04/21.
//

import UIKit
import SwiftUI
import Domain
import Repository
import Scene
import Testing

public final class AddCitySceneBuilderImp: AddCitySceneBuilder {
    private let detailCitySceneBuilder: CityDetailSceneBuilder
    
    public init(detailCitySceneBuilder: CityDetailSceneBuilder) {
        self.detailCitySceneBuilder = detailCitySceneBuilder
    }
    
    public func makeAddCityScene() -> UIViewController {
        let isTesting = true
        if isTesting {
            let repository = MockingRepository(dataStore: FakeDataStore.shared)
            let useCase = MockingFindLocationUseCase(repository: repository)
            let viewModel = AddCityViewModel(useCase: useCase)
            let addCityView = AddCityView(viewModel: viewModel)
            let router = AddCityRouter(detailCitySceneBuilder: self.detailCitySceneBuilder)
            let viewControlelr = UIHostingController(rootView: addCityView)
            viewModel.router = router
            router.scene = viewControlelr
            return viewControlelr
        } else {
            let repository = Repository(dataStore: DataStore.shared, remote: Remote())
            let useCase = FindLocationUseCase(repository: repository)
            let viewModel = AddCityViewModel(useCase: useCase)
            let addCityView = AddCityView(viewModel: viewModel)
            let router = AddCityRouter(detailCitySceneBuilder: self.detailCitySceneBuilder)
            let viewControlelr = UIHostingController(rootView: addCityView)
            viewModel.router = router
            router.scene = viewControlelr
            return viewControlelr
        }
    }
}
