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
    public init() { }
    
    public func makeAddCityScene() -> UIViewController {
        let repository = Repository(remote: Remote())
        let useCase = FindLocationUseCase(repository: repository)
        let viewModel = AddCityViewModel(useCase: useCase)
        let addCityView = AddCityView(viewModel: viewModel)
        let viewControlelr = UIHostingController(rootView: addCityView)
        return viewControlelr
    }
}
