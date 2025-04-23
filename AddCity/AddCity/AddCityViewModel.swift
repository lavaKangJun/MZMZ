//
//  AddCityViewModel.swift
//  AddCity
//
//  Created by 강준영 on 2025/04/23.
//

import Foundation
import Combine
import Domain

public final class AddCityViewModel: ObservableObject {
    private let useCase: FindLocationUseCaseProtocol
    private let locationResult = CurrentValueSubject<[String], Never>([])

    init(useCase: FindLocationUseCaseProtocol) {
        self.useCase = useCase
    }
    
    var locations: AnyPublisher<[String], Never> {
        return self.locationResult.removeDuplicates().eraseToAnyPublisher()
    }
    
    func searchText(_ text: String) {
        Task {
            let location = try await useCase.findLocation(location: text)
            print(location)
            self.locationResult.send(location.map({ $0.addressName }))
        }
    }
}
