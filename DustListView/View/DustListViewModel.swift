//
//  DustListViewModel.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import UIKit
import Combine
import Domain
import WidgetKit

public final class DustListViewModel {
    private let locationService: LocationServiceProtocol
    private let usecase: DustListUseCaseProtocol
    private let authKey = "16f1ed764daa4d2c4d6e3f0d25269ca5"
    private let dustListSubject = CurrentValueSubject<[DustListViewDataModel], Never>([])
    private let errorSubject = PassthroughSubject<String, Never>()
    public var router: DustListRouting?
    
    public var dustListStream: AnyPublisher<[DustListViewDataModel], Never> {
        return self.dustListSubject.eraseToAnyPublisher()
    }
    
    public var errorStream: AnyPublisher<String, Never> {
        return self.errorSubject.eraseToAnyPublisher()
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
                let dataModels = try await withThrowingTaskGroup(of: (Int, DustListViewDataModel).self) { group in
                    for (index, dustInfo) in dustInfos.enumerated() {
                        group.addTask {
                            guard let latitude = Double(dustInfo.latitude),
                                  let longtitude = Double(dustInfo.longitude),
                                  let location = try await self.usecase.convertoToTMCoordinate(latitude: latitude, longtitude: longtitude),
                                  let mesureDnsty = try await self.usecase.fetchMesureDnsty(tmX: location.x, tmY: location.y) else { return (index, DustListViewDataModel(location: dustInfo.location, longtitude: Double(dustInfo.longitude) ?? 0, latitude: Double(dustInfo.latitude) ?? 0)) }
                            return (index, DustListViewDataModel(
                                entity: mesureDnsty,
                                location: dustInfo.location,
                                longtitude: longtitude,
                                latitude: latitude)
                            )
                        }
                    }
                    
                    var result: [(Int, DustListViewDataModel)] = []
                    for try await model in group {
                        result.append(model)
                    }
                    return result.sorted(by: { $0.0 < $1.0 }).map({ $0.1 })
                }
         
                await MainActor.run {
                    self.dustListSubject.send(dataModels)
                }
                
                WidgetCenter.shared.reloadTimelines(ofKind: "MZMZWidzet")
            } catch {
                await MainActor.run {
                    self.errorSubject.send(error.localizedDescription)
                }
            }
        }
    }
    
    public func deleteLocation(_ locaion: String) {
        let _ = self.usecase.deleteDustInfo(location: locaion)
        var current = self.dustListSubject.value
        current.removeAll(where: { $0.location == locaion })
        self.dustListSubject.send(current)
        
        WidgetCenter.shared.reloadTimelines(ofKind: "MZMZWidzet")
    }
    
    public func routeToFindLocation() {
        self.router?.routeToFindLocation()
    }
    
    public func routeToDetail(name: String, longitude: Double, latitude: Double) {
        self.router?.routeToDetail(name: name, longitude: "\(longitude)", latitude: "\(latitude)")
    }
}
