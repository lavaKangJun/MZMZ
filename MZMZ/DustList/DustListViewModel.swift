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
    private let repository: RepositoryProtocol
    private let authKey = "16f1ed764daa4d2c4d6e3f0d25269ca5"
    
    init(repository: RepositoryProtocol, locationService: LocationServiceProtocol, usecase: DustListUseCaseProtocol) {
        self.locationService = locationService
        self.usecase = usecase
        self.repository = repository
        
        
        Task {
            guard let location = self.locationService.getLocation() else { return }
            print(location)
            do {
                let location = try await repository.formatTMCoordinate(locationInfo: location, key: authKey)
                print("location", location)
            } catch {
                print(error)
            }
        }
    }
    
    func fetchDust() -> [DustListViewDataModel] {
        return self.usecase.fetchDust().map { DustListViewDataModel($0) }
    }
}
