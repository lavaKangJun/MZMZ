//
//  DustListViewModel.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import UIKit
@preconcurrency import Combine
import Domain
import Common
import WidgetKit

public final class DustListViewModel: @unchecked Sendable   {
    private let usecase: DustListUseCaseProtocol
    private let dustListSubject = CurrentValueSubject<[DustListViewDataModel], Never>([])
    private let errorSubject = PassthroughSubject<String, Never>()
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    public var router: DustListRouting?
    
    public var dustListStream: AnyPublisher<[DustListViewDataModel], Never> {
        return self.dustListSubject.eraseToAnyPublisher()
    }
    
    public var errorStream: AnyPublisher<String, Never> {
        return self.errorSubject.eraseToAnyPublisher()
    }
    
    public var isLoadingStream: AnyPublisher<Bool, Never> {
        return self.isLoadingSubject.eraseToAnyPublisher()
    }
    
    public init(usecase: DustListUseCaseProtocol) {
        self.usecase = usecase
        self.isLoadingSubject.send(true)
    }
    
    public func fetchDust() {
        Task {
            do {
                let dataModels = try await self.loadData()
                await MainActor.run { [weak self] in
                    self?.dustListSubject.send(dataModels)
                    self?.isLoadingSubject.send(false)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.errorSubject.send(error.localizedDescription)
                    self?.isLoadingSubject.send(false)
                }
            }
        }
    }
    
    public func refresh() async {
        do {
            let models = try await self.loadData()
            await MainActor.run { [weak self] in
                self?.dustListSubject.send(models)
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.errorSubject.send(error.localizedDescription)
            }
        }
    }
    
    private func loadData() async throws -> [DustListViewDataModel] {
            let dustInfos = try self.usecase.getDustInfo()
            return try await withThrowingTaskGroup(of: (Int, DustListViewDataModel).self) { group in
                for (index, dustInfo) in dustInfos.enumerated() {
                    group.addTask { [dustInfo] in
                        let entity = LocationInfoEntity(latitude: dustInfo.latitude, longtitude: dustInfo.longitude)
                        var tmX: Double?
                        var tmY: Double?
                        if let _tmX = dustInfo.tmX, let _tmY = dustInfo.tmY {
                            tmX = _tmX
                            tmY = _tmY
                        } else {
                            let location = try await self.usecase.convertoToTMCoordinate(location: entity)
                            tmX = location?.x
                            tmY = location?.y
                        }
                        guard
                            let tmX, let tmY,
                            let mesureDnsty = try await self.usecase.fetchMesureDnsty(tmX: tmX, tmY: tmY) else {
                            let dataModel = DustListViewDataModel(
                                location: dustInfo.location,
                                station: nil,
                                longtitude: dustInfo.longitude,
                                latitude: dustInfo.latitude,
                                isFavorite: dustInfo.isFavorite
                            )
                            return (index, dataModel)
                        }
                        return (index, DustListViewDataModel(
                            entity: mesureDnsty,
                            location: dustInfo.location,
                            longtitude: dustInfo.longitude,
                            latitude: dustInfo.latitude,
                            tmX: tmX,
                            tmY: tmY,
                            isFavorite: dustInfo.isFavorite)
                        )
                    }
                }
                
                var result: [(Int, DustListViewDataModel)] = []
                for try await model in group {
                    result.append(model)
                }
                return result.sorted(by: { $0.0 < $1.0 }).map({ $0.1 })
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
        dustDensity: String,
        microDustDensity: String,
        dustGrade: AirQualityGrade,
        microDustGrade: AirQualityGrade,
        isFavorite: Bool
    ) {
        let dismiss: () -> Void = { [weak self] in
            self?.fetchDust()
        }
        self.router?.routeToDetail(
            name: name,
            station: station,
            dustDensity: dustDensity,
            microDustDensity: microDustDensity,
            dustGrade: dustGrade,
            microDustGrade: microDustGrade,
            isFavorite: isFavorite,
            dismiss: dismiss
        )
    }
}
