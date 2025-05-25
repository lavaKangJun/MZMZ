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
    
    init(entity: MesureDnstyEntity, location: String, longtitude: Double, latitude: Double) {
        self.location = location
        self.dustDensity = entity.pm10Value
        self.microDustDensity = entity.pm25Value
        self.longtitude = longtitude
        self.latitude = latitude
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
    
    var backgroundColor: [Color] {
        guard let gradeValue = Int(dustDensity) else { return [Color.clear] }
        if 0...30 ~= gradeValue {
            return [Color.blue.opacity(0.5)]
        } else if 31...80 ~= gradeValue {
            return [Color.blue.opacity(0.5), Color.black.opacity(0.1)]
        } else if 81...150 ~= gradeValue {
            return [Color.blue.opacity(0.5), Color.black.opacity(0.5)]
        } else {
            return [Color.blue.opacity(0.3), Color.black.opacity(0.8)]
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
    
    public static func ==(lhs: DustListViewDataModel, rhs: DustListViewDataModel) -> Bool {
        return lhs.location == rhs.location
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.location)
    }
}
