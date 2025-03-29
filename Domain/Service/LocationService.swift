//
//  LocationService.swift
//  Domain
//
//  Created by 강준영 on 2025/03/22.
//

import Foundation
import CoreLocation

public protocol LocationServiceProtocol {
    func getLocation() -> LocationInfoEntity?
}

public final class LocationService: NSObject, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    
    public override init() {
        super.init()
        setupInit()
    }
    
    private func setupInit() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    public func getLocation() -> LocationInfoEntity? {
        guard let coordinate = locationManager.location?.coordinate else { return nil }
        return LocationInfoEntity(latitude: coordinate.latitude, longtitude: coordinate.longitude)
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
}
