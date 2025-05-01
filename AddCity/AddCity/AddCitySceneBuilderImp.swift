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

public final class AddCitySceneBuilderImp: AddCitySceneBuilder {
    private let detailCitySceneBuilder: CityDetailSceneBuilder
    
    public init(detailCitySceneBuilder: CityDetailSceneBuilder) {
        self.detailCitySceneBuilder = detailCitySceneBuilder
    }
    
    public func makeAddCityScene() -> UIViewController {
        let repository = Repository(remote: Remote())
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
