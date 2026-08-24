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

@Observable
public final class DustListViewModel: @unchecked Sendable   {
    private let usecase: DustListUseCaseProtocol
    var dustListModels: [DustListViewDataModel] = []
    var errorMessage: String = ""
    var showError = false
    var isLoading = false
    @ObservationIgnored public var router: DustListRouting?
    
    public init(usecase: DustListUseCaseProtocol) {
        self.usecase = usecase
        self.isLoading = true
    }
    
    public func fetchDust() {
        Task {
            do {
                let dataModels = try await self.loadData()
                await MainActor.run { [weak self] in
                    self?.dustListModels = dataModels
                    self?.isLoading = false
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    self?.isLoading = false
                }
            }
        }
    }
    
    public func refresh() async {
        do {
            let models = try await self.loadData()
            await MainActor.run { [weak self] in
                self?.dustListModels = models
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.showError = true
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func loadData() async throws -> [DustListViewDataModel] {
        let dustInfos = try self.usecase.getDustInfo()
        return try await withThrowingTaskGroup(of: (Int, DustListViewDataModel).self) { group in
            for (index, dustInfo) in dustInfos.enumerated() {
                group.addTask { [dustInfo] in
                    
                    let dustDetailInfo = try await self.usecase.nearestStationDustInfo(lat: dustInfo.latitude, lng: dustInfo.longitude)
                    return (index, DustListViewDataModel(
                        entity: dustDetailInfo,
                        location: dustInfo.location,
                        longtitude: dustInfo.longitude,
                        latitude: dustInfo.latitude,
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
            self.errorMessage = "delete fail"
            self.showError = true
            return
        }
        
        var current = self.dustListModels
        current.removeAll(where: { $0.location == locaion })
        self.dustListModels = current
        
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
