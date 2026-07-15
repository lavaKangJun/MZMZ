//
//  CityDetailSceneBuilderImp.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import SwiftUI
import Scene
import Domain
import Repository

final public class CityDetailSceneBuilderImp: @preconcurrency CityDetailSceneBuilder {
    
    public init() { }
    
    @MainActor public func makeCityDetailScene(_ dependency: CityDetailDependency) -> UIViewController {
        let remote = Remote()
        let repository = Repository(dataStore: DataStore.shared, remote: remote)
        let viewModel = CityDetailViewModel(
            detailViewType: dependency.detailViewType,
            dismiss: dependency.dismiss,
            usecase: DustInfoUseCase(repository: repository)
        )
        let router = CityDetailRouter()
        let cityDetailView = CityDetailView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: cityDetailView)
        viewModel.router = router
        router.scene = viewController
        return viewController
    }
}
