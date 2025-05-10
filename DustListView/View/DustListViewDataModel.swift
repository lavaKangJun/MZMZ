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
    let microDustDensity: String
    
    init(entity: MesureDnstyEntity, location: String) {
        self.location = location
        self.dustDensity = entity.pm10Value
        self.microDustDensity = entity.pm25Value
    }
    
    var dustGradeText: String {
        guard let gradeValue = Int(dustDensity) else { return "" }
        if 0...30 ~= gradeValue {
            return "좋음"
        } else if 31...80 ~= gradeValue {
            return "보통"
        } else if 81...150 ~= gradeValue {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
        
    }
    
    var microDustGradeText: String {
        guard let gradeValue = Int(microDustDensity) else { return "" }
        if 0...15 ~= gradeValue {
            return "좋음"
        } else if 16...50 ~= gradeValue {
            return "보통"
        } else if 51...100 ~= gradeValue {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
    }
}
