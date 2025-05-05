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

final public class CityDetailSceneBuilderImp: CityDetailSceneBuilder {
    
    public init() { }
    
    public func makeCityDetailScene(_ dependency: CityDetailDependency) -> UIViewController {
        let remote = Remote()
        let repository = Repository(remote: remote)
        let viewModel = CityDetailViewModel(
            name: dependency.name,
            longitude: dependency.longitude,
            latitude: dependency.latitude,
            isSearchResult: dependency.isSearchResult,
            usecase: DustInfoUseCase(repository: repository)
        )
        let cityDetailView = CityDetailView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: cityDetailView)
        return viewController
    }
}
