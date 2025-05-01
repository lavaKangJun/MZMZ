//
//  CityDetailViewModel.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import Foundation

public final class CityDetailViewModel: ObservableObject {
    private let name: String
    private let longitude: String
    private let latitude: String
    
    @Published var dummyData: String = ""
    
    init(name: String, longitude: String, latitude: String) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.dummyData = name
    }
    
    // 검색을 통해 들어온 경우 '추가' 버튼을 통해 지역 저정
    func saveCity() {
        
    }
}
