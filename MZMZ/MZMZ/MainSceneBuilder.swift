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

final class MainSceneBuilder {
    func makeMainScene() -> UIViewController {
        let repository = MockingRepository()
        let useCase = DustListUseCase(repository: repository)
        let viewModel = DustListViewModel(usecase: useCase)
        let listView = DustListView(viewModel: viewModel)
        let viewControlelr = UIHostingController(rootView: listView)
        return viewControlelr
    }
}
