//
//  DustListViewModel.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation
import Domain

final class DustListViewModel {
    private let locationService: LocationServiceProtocol
    private let usecase: DustListUseCaseProtocol
    
    init(locationService: LocationServiceProtocol, usecase: DustListUseCaseProtocol) {
        self.locationService = locationService
        self.usecase = usecase
        
        let location = self.locationService.getLocation()
        print(location)
    }
    
    func fetchDust() -> [DustListViewDataModel] {
        return self.usecase.fetchDust().map { DustListViewDataModel($0) }
    }
}
