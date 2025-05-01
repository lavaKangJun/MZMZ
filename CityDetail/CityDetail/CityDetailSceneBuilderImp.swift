//
//  CityDetailSceneBuilderImp.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import SwiftUI
import Scene

final public class CityDetailSceneBuilderImp: CityDetailSceneBuilder {
    
    public init() { }
    
    public func makeCityDetailScene(_ dependency: CityDetailDependency) -> UIViewController {
        
        let viewModel = CityDetailViewModel(
            name: dependency.name,
            longitude: dependency.longitude,
            latitude: dependency.latitude
        )
        let cityDetailView = CityDetailView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: cityDetailView)
        return viewController
    }
}
