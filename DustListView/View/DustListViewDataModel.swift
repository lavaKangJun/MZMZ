//
//  DustListViewDataModel.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import Foundation
import SwiftUI
import Domain

public final class DustListViewDataModel: Hashable {
    let location: String
    let dustDensity: String
    let microDustDensity: String
    let longtitude: Double
    let latitude: Double
    var dustGrade: Int = 0
    var microDustGrade: Int = 0
    
    init(entity: MesureDnstyEntity, location: String, longtitude: Double, latitude: Double) {
        self.location = location
        self.dustDensity = entity.pm10Value
        self.microDustDensity = entity.pm25Value
        self.longtitude = longtitude
        self.latitude = latitude
        self.dustGrade = translateDustGrade(dustDensity)
        self.microDustGrade = translateMicroDustGrade(microDustDensity)
    }
    
    init(location: String, longtitude: Double, latitude: Double) {
        self.location = location
        self.dustDensity = "-1"
        self.microDustDensity = "-1"
        self.longtitude = longtitude
        self.latitude = latitude
        self.dustGrade = translateDustGrade(dustDensity)
        self.microDustGrade = translateMicroDustGrade(microDustDensity)
    }
    
    private func translateDustGrade(_ value: String) -> Int {
        guard let gradeValue = Int(value) else { return 0 }
        if -1 == gradeValue {
            return -1
        } else if 0...30 ~= gradeValue {
            return 0
        } else if 31...80 ~= gradeValue {
            return 1
        } else if 81...150 ~= gradeValue {
            return 2
        } else {
            return 3
        }
    }
    
    private func translateMicroDustGrade(_ value: String) -> Int {
        guard let gradeValue = Int(value) else { return 0 }
        if -1 == gradeValue {
            return -1
        } else if 0...15 ~= gradeValue {
            return 0
        } else if 16...50 ~= gradeValue {
            return 1
        } else if 50...100 ~= gradeValue {
            return 2
        } else {
            return 3
        }
    }
}

extension DustListViewDataModel {
    public static func ==(lhs: DustListViewDataModel, rhs: DustListViewDataModel) -> Bool {
        return lhs.location == rhs.location
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.location)
    }
}

extension DustListViewDataModel {
    var dustIsInspect: Bool {
        return self.dustGrade == -1
    }
    
    var microIsInspect: Bool {
        return self.microDustGrade == -1
    }
    
    var dustGradeText: String {
        guard let gradeValue = Int(dustDensity) else { return "" }
        if gradeValue == -1 {
          return "점검중"
        } else if 0...30 ~= gradeValue {
            return "좋음"
        } else if 31...80 ~= gradeValue {
            return "보통"
        } else if 81...150 ~= gradeValue {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
    }
    
    var backgroundColor: [Color] {
        let grade = dustGrade > microDustGrade ? dustGrade : microDustGrade
        switch grade {
        case -1:
            return [Color.gray.opacity(0.5)]
        case 0:
            return [Color.blue.opacity(0.5)]
        case 1:
            return [Color.blue.opacity(0.5), Color.black.opacity(0.1)]
        case 2:
            return [Color.blue.opacity(0.5), Color.black.opacity(0.5)]
        default:
            return [Color.blue.opacity(0.3), Color.black.opacity(0.8)]
        }
    }
    
    var microDustGradeText: String {
        guard let gradeValue = Int(microDustDensity) else { return "" }
        if gradeValue == -1 {
            return "점검중"
        } else if 0...15 ~= gradeValue {
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
