//
//  AddCityViewModel.swift
//  AddCity
//
//  Created by 강준영 on 2025/04/23.
//

import Foundation
import Combine
import Domain
import Scene


public struct CityPresentable {
    public let name: String
    public let longitude: String
    public let latitude: String
    
    init(_ entity: SearchLocationEntity) {
        self.name = entity.addressName
        self.longitude = entity.longitude
        self.latitude = entity.latitude
    }
}

@Observable
public final class AddCityViewModel: @unchecked Sendable {
    private let useCase: FindLocationUseCaseProtocol
    public var cityCellViewModels: [CityPresentable] = []
    @ObservationIgnored public var router: AddCityRouter?
    
    init(useCase: FindLocationUseCaseProtocol) {
        self.useCase = useCase
    }

    func searchText(_ text: String) {
        guard text.isEmpty == false else { return }
        Task {
            do {
                let locations = try await useCase.findLocation(location: text)
                await MainActor.run {
                    self.cityCellViewModels = locations.map({ CityPresentable($0) })
                }
            } catch { }
        }
    }
    
    @MainActor func clearSearch() {
        self.router?.dismiss()
    }
    
    @MainActor func routeToCityDetail(_ dependency: CityDetailDependency) {
        self.router?.routeToCityDetail(dependency: dependency)
    }
}
