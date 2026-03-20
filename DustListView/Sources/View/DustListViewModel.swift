//
//  DustListViewModel.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import UIKit
@preconcurrency import Combine
import Domain
import WidgetKit

public final class DustListViewModel: @unchecked Sendable   {
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
    
    public init(usecase: DustListUseCaseProtocol) {
        self.usecase = usecase
    }
    
    public func fetchDust() {
        Task {
            do {
                let dustInfos = try self.usecase.getDustInfo()
                let dataModels = try await withThrowingTaskGroup(of: (Int, DustListViewDataModel).self) { group in
                    for (index, dustInfo) in dustInfos.enumerated() {
                        group.addTask { [dustInfo] in
                            let entity = LocationInfoEntity(latitude: dustInfo.latitude, longtitude: dustInfo.longitude)
                            guard let location = try await self.usecase.convertoToTMCoordinate(location: entity),
                                  let mesureDnsty = try await self.usecase.fetchMesureDnsty(tmX: location.x, tmY: location.y) else { return (index, DustListViewDataModel(location: dustInfo.location, station: nil, longtitude: dustInfo.longitude, latitude: dustInfo.latitude)) }
                            return (index, DustListViewDataModel(
                                entity: mesureDnsty,
                                location: dustInfo.location,
                                longtitude: dustInfo.longitude,
                                latitude: dustInfo.latitude)
                            )
                        }
                    }
                    
                    var result: [(Int, DustListViewDataModel)] = []
                    for try await model in group {
                        result.append(model)
                    }
                    return result.sorted(by: { $0.0 < $1.0 }).map({ $0.1 })
                }
         
                await MainActor.run { [weak self] in
                    self?.dustListSubject.send(dataModels)
                }
                
                WidgetCenter.shared.reloadTimelines(ofKind: "MZMZWidzet")
            } catch {
                await MainActor.run { [weak self] in
                    self?.errorSubject.send(error.localizedDescription)
                }
            }
        }
    }
    
    public func deleteLocation(_ locaion: String) {
        let result = self.usecase.deleteDustInfo(location: locaion)
        guard result == true else {
            self.errorSubject.send("delete fail")
            return
        }
        
        var current = self.dustListSubject.value
        current.removeAll(where: { $0.location == locaion })
        self.dustListSubject.send(current)
        
        WidgetCenter.shared.reloadTimelines(ofKind: "MZMZWidzet")
    }
    
    @MainActor
    public func routeToFindLocation() {
        self.router?.routeToFindLocation()
    }
    
    @MainActor
    public func routeToDetail(
        name: String,
        station: String?,
        longitude: String,
        latitude: String
    ) {
        self.router?.routeToDetail(name: name, station: station, longitude: longitude, latitude: latitude)
    }
}
