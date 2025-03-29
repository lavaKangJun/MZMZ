//
//  DustListViewDataModel.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import Foundation
import Domain

public final class DustListViewDataModel: Identifiable {
    let location: String
    let dustDensity: String
    let dustGrade: String?
    let microDustDensity: String
    let microDustGrade: String?
    
    init(_ entity: MesureDnstyEntity) {
        self.location = entity.location
        self.dustDensity = entity.pm10Value
        self.dustGrade = entity.pm10Grade
        self.microDustDensity = entity.pm25Value
        self.microDustGrade = entity.pm25Grade
    }
}
