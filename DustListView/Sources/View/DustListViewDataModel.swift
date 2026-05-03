//
//  DustListViewDataModel.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import Foundation
import SwiftUI
import Domain

public final class DustListViewDataModel: Hashable, @unchecked Sendable {
    let location: String
    let station: String?
    let dustDensity: String
    let microDustDensity: String
    let longtitude: String
    let latitude: String
    var dustGrade: Int = 0
    var microDustGrade: Int = 0
    var isFavorite: Bool = false
    
    init(entity: MesureDnstyEntity, location: String, longtitude: String, latitude: String, isFavorite: Bool) {
        self.location = location
        self.station = entity.location
        self.dustDensity = entity.pm10Value
        self.microDustDensity = entity.pm25Value
        self.longtitude = longtitude
        self.latitude = latitude
        self.dustGrade = translateDustGrade(dustDensity)
        self.microDustGrade = translateMicroDustGrade(microDustDensity)
        self.isFavorite = isFavorite
    }
    
    init(location: String, station: String?, longtitude: String, latitude: String, isFavorite: Bool) {
        self.location = location
        self.station = station
        self.dustDensity = "-1"
        self.microDustDensity = "-1"
        self.longtitude = longtitude
        self.latitude = latitude
        self.dustGrade = translateDustGrade(dustDensity)
        self.microDustGrade = translateMicroDustGrade(microDustDensity)
        self.isFavorite = isFavorite
    }
    
    private func translateDustGrade(_ value: String) -> Int {
        guard let gradeValue = Int(value) else { return 0 }
        if gradeValue == -1 {
            return -1
        } else if 0...45 ~= gradeValue {
            return 0
        } else if 46...50 ~= gradeValue {
            return 1
        } else if 51...75 ~= gradeValue {
            return 2
        } else if 76...100 ~= gradeValue {
            return 3
        } else {
            return 4
        }
    }
    
    private func translateMicroDustGrade(_ value: String) -> Int {
        guard let gradeValue = Int(value) else { return 0 }
        if gradeValue == -1{
            return -1
        } else  if 0...15 ~= gradeValue {
            return 0
        } else if 16...25 ~= gradeValue {
            return 1
        } else if 26...37 ~= gradeValue {
            return 2
        } else if 38...50 ~= gradeValue {
            return 3
        } else {
            return 4
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
        } else if 0...45 ~= gradeValue {
            return "좋음"
        } else if 46...50 ~= gradeValue {
            return "보통"
        } else if 51...75 ~= gradeValue {
            return "주의"
        } else if 76...100 ~= gradeValue {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
    }
    
    var backgroundColor: [Color] {
        let grade = dustGrade > microDustGrade ? dustGrade : microDustGrade
        switch grade {
        case -1:
            return [Color.gray.opacity(0.6)]
        case 0:
            return [Color.blue.opacity(0.5)]
        case 1:
            return [Color.blue.opacity(0.5), Color.black.opacity(0.2)]
        case 2:
            return [Color.blue.opacity(0.5), Color.black.opacity(0.6)]
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
        } else if 16...25 ~= gradeValue {
            return "보통"
        } else if 26...37 ~= gradeValue {
            return "주의"
        } else if 38...50 ~= gradeValue {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
    }
}
