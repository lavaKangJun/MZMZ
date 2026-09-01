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
    /// 진행 중인 검색. 다음 입력이 들어오면 취소한다.
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    
    init(useCase: FindLocationUseCaseProtocol) {
        self.useCase = useCase
    }
    
    deinit {
        searchTask?.cancel()
    }

    /// 검색어가 바뀔 때마다 호출된다(글자 단위).
    ///
    /// 취소 없이 그냥 던지면 "서울" 을 칠 때 ㅅ/서/설/서우/서울 요청이 전부
    /// 동시에 떠 있고, 응답 순서는 보장되지 않는다. "서울" 결과가 먼저 오고
    /// "서" 결과가 나중에 오면 화면엔 "서" 의 결과가 남는다.
    /// 그래서 새 입력마다 이전 검색을 취소하고, 300ms 쉬었다 보낸다.
    @MainActor
    func searchText(_ text: String) {
        self.searchTask?.cancel()
        
        guard text.isEmpty == false else { return }
        
        self.searchTask = Task { [weak self] in
            // 이 사이에 다음 글자가 들어오면 위에서 취소돼 여기서 끝난다.
            try? await Task.sleep(for: .milliseconds(300))
            guard Task.isCancelled == false, let self else { return }
            
            guard let locations = try? await self.useCase.findLocation(location: text) else { return }
            
            // 응답을 기다리는 동안 검색어가 또 바뀌었으면 덮어쓰지 않는다.
            guard Task.isCancelled == false else { return }
            
            await MainActor.run {
                self.cityCellViewModels = locations.map({ CityPresentable($0) })
            }
        }
    }
    
    @MainActor func claer() {
        self.searchTask?.cancel()
        self.cityCellViewModels = []
    }
    
    @MainActor func dismiss() {
        self.router?.dismiss()
    }
    
    @MainActor func routeToCityDetail(_ dependency: CityDetailDependency) {
        self.router?.routeToCityDetail(dependency: dependency)
    }
}
