//
//  Builder.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/08.
//

import Foundation

final class ApplicationRootBuilder {
    func makeRootViewModel() -> ApplicationRootViewModel {
        let viewModel = ApplicationRootViewModel()
        viewModel.router = ApplicationRouter()
        return viewModel
    }
}
