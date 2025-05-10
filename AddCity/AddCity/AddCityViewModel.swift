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

public final class AddCityViewModel: ObservableObject {
    private let useCase: FindLocationUseCaseProtocol
    private let locationResult = CurrentValueSubject<[SearchLocationEntity], Never>([])
    @Published public var cityCellViewModel: [CityPresentable] = []
    public var router: AddCityRouter?
    
    init(useCase: FindLocationUseCaseProtocol) {
        self.useCase = useCase
        
        self.locationResult
            .map{ $0.map{ CityPresentable($0) }}
            .receive(on: DispatchQueue.main)
            .assign(to: &$cityCellViewModel)
    }

    func searchText(_ text: String) {
        guard text.isEmpty == false else { return }
        Task {
            let location = try await useCase.findLocation(location: text)
            self.locationResult.send(location)
        }
    }
    
    func clearSearch() {
        //self.locationResult.send([])
        self.router?.dismiss()
    }
    
    func routeToCityDetail(_ dependency: CityDetailDependency) {
        self.router?.routeToCityDetail(dependency: dependency)
    }
}
