//
//  DustListViewModel.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import UIKit
import Combine
import Domain

public final class DustListViewModel {
    private let locationService: LocationServiceProtocol
    private let usecase: DustListUseCaseProtocol
    private let repository: RepositoryProtocol
    private let authKey = "16f1ed764daa4d2c4d6e3f0d25269ca5"
    private let dustListSubject = CurrentValueSubject<[DustListViewDataModel], Never>([])
    public var router: DustListRouting?
    
    public var dustListStream: AnyPublisher<[DustListViewDataModel], Never> {
        return self.dustListSubject.eraseToAnyPublisher()
    }
    
    public init(
        repository: RepositoryProtocol,
        locationService: LocationServiceProtocol,
        usecase: DustListUseCaseProtocol
    ) {
        self.locationService = locationService
        self.usecase = usecase
        self.repository = repository
        
        fetchDust()
    }
    
    public func fetchDust() {
        Task {
            do {
                guard let location = try await self.usecase.fetchLocation() else { return }
                guard let mesureDnsty = try await self.usecase.fetchMesureDnsty(tmX: location.x, tmY: location.y) else { return }
                self.dustListSubject.send([DustListViewDataModel(mesureDnsty)])
            } catch {
                print(error)
            }
        }
    }
    
    public func routeToFindLocation() {
        self.router?.routeToFindLocation()
    }
}
