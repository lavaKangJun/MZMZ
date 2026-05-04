//
//  DustListViewDataModel.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import Foundation
import SwiftUI
import Domain
import Common

public final class DustListViewDataModel: Hashable, @unchecked Sendable {
    let location: String
    let station: String?
    let dustDensity: String
    let microDustDensity: String
    let longtitude: String
    let latitude: String
    var isFavorite: Bool = false
    var dustGrade: AirQualityGrade
    var microDustGrade: AirQualityGrade
    
    init(entity: MesureDnstyEntity, location: String, longtitude: String, latitude: String, isFavorite: Bool) {
        self.location = location
        self.station = entity.location
        self.dustDensity = entity.pm10Value
        self.microDustDensity = entity.pm25Value
        self.longtitude = longtitude
        self.latitude = latitude
        self.isFavorite = isFavorite
        self.dustGrade = AirQualityGrade.grade(forPM10: dustDensity)
        self.microDustGrade = AirQualityGrade.grade(forPM10: microDustDensity)
    }
    
    init(location: String, station: String?, longtitude: String, latitude: String, isFavorite: Bool) {
        self.location = location
        self.station = station
        self.dustDensity = "-1"
        self.microDustDensity = "-1"
        self.longtitude = longtitude
        self.latitude = latitude
        self.isFavorite = isFavorite
        self.dustGrade = AirQualityGrade.grade(forPM10: dustDensity)
        self.microDustGrade = AirQualityGrade.grade(forPM10: microDustDensity)

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
        return self.dustGrade == .checking
    }
    
    var microIsInspect: Bool {
        return self.microDustGrade == .checking
    }
}
