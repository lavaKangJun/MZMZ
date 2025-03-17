//
//  DustListViewModel.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation
import Domain

final class DustListViewModel {
    private let usecase: DustListUseCaseProtocol
    
    init(usecase: DustListUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func fetchDust() -> [DustListViewDataModel] {
        return self.usecase.fetchDust().map { DustListViewDataModel($0) }
    }
}
