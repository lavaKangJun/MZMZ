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
    private let authKey = "16f1ed764daa4d2c4d6e3f0d25269ca5"
    private let dustListSubject = CurrentValueSubject<[DustListViewDataModel], Never>([])
    public var router: DustListRouting?
    
    public var dustListStream: AnyPublisher<[DustListViewDataModel], Never> {
        return self.dustListSubject.eraseToAnyPublisher()
    }
    
    public init(
        locationService: LocationServiceProtocol,
        usecase: DustListUseCaseProtocol
    ) {
        self.locationService = locationService
        self.usecase = usecase
    }
    
    public func fetchDust() {
        Task {
            do {
                let dustInfos = self.usecase.getDustInfo()
          
                let dataModels = try await withThrowingTaskGroup(of: DustListViewDataModel?.self) { group in
                    for dustInfo in dustInfos {
                        group.addTask {
                            guard let latitude = Double(dustInfo.latitude),
                                  let longtitude = Double(dustInfo.longitude),
                                  let location = try await self.usecase.convertoToTMCoordinate(latitude: latitude, longtitude: longtitude),
                                  let mesureDnsty = try await self.usecase.fetchMesureDnsty(tmX: location.x, tmY: location.y) else { return nil }
                            return DustListViewDataModel(entity: mesureDnsty, location: dustInfo.location)
                        }
                    }
                    
                    var result: [DustListViewDataModel] = []
                    for try await model in group {
                        if let model = model {
                            result.append(model)
                        }
                    }
                    return result
                }
         
                await MainActor.run {
                    print("dataModels", dataModels)
                    self.dustListSubject.send(dataModels)
                }
            } catch {
                print(error)
            }
        }
    }
    
    public func routeToFindLocation() {
        self.router?.routeToFindLocation()
    }
}
