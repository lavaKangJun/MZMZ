//
//  StubLocationService.swift
//  Testing
//
//  Created by 강준영 on 2025/03/29.
//

import Foundation
import Domain

public class StubLocationService: LocationServiceProtocol {
    
    public init() { }
    
    public func getLocation() -> LocationInfoEntity? {
        return LocationInfoEntity(latitude: "37.53805454557308", longtitude: "127.12188247653779")
    }
}
