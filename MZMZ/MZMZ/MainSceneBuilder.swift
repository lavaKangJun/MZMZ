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
import Testing
import DustListView

final class MainSceneBuilder {
    func makeMainScene() -> UIViewController {
        let isTesting = true
        if isTesting {
            let repository = MockingRepository()
            let locationService = MockingLocationService()
            let useCase = MockingDustListUseCase(repository: repository, locationService: locationService)
            let viewModel = DustListViewModel(repository: repository, locationService: locationService, usecase: useCase)
            let listView = DustListView(viewModel: viewModel)
            let viewControlelr = UIHostingController(rootView: listView)
            return viewControlelr
        } else {
            let repository = Repository(remote: Remote())
            let locationService = LocationService()
            let useCase = DustListUseCase(repository: repository, locationService: locationService)
            let viewModel = DustListViewModel(repository: repository, locationService: locationService, usecase: useCase)
            let listView = DustListView(viewModel: viewModel)
            let viewControlelr = UIHostingController(rootView: listView)
            return viewControlelr
        }
    }
}
