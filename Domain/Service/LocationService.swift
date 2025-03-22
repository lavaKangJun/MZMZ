//
//  LocationService.swift
//  Domain
//
//  Created by 강준영 on 2025/03/22.
//

import Foundation
import CoreLocation

public protocol LocationServiceProtocol {
    func getLocation() -> LocationInfo?
}

public struct LocationInfo: Decodable {
    public let latitude: Double
    public let longtitude: Double
}

public struct TMLocationDocument: Decodable {
    public let documents: [TMLocationInfo]
}

public struct TMLocationInfo: Decodable {
    public let x: Double
    public let y: Double
}

public final class LocationService: NSObject, LocationServiceProtocol {
    public static let shared = LocationService()
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    public func getLocation() -> LocationInfo? {
        guard let coordinate = locationManager.location?.coordinate else { return nil }
        return LocationInfo(latitude: coordinate.latitude, longtitude: coordinate.longitude)
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
}
