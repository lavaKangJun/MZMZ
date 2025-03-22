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

final class MainSceneBuilder {
    func makeMainScene() -> UIViewController {
       // let repository = MockingRepository()
        let remote = Remote()
        let repository = Repository(remote: remote)
        let useCase = DustListUseCase(repository: repository)
        let locationService = LocationService.shared
        let viewModel = DustListViewModel(repository: repository, locationService: locationService, usecase: useCase)
        let listView = DustListView(viewModel: viewModel)
        let viewControlelr = UIHostingController(rootView: listView)
        return viewControlelr
    }
}
