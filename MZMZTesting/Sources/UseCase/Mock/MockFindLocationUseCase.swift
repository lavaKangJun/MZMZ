//
//  MockFindLocationUseCase.swift
//  MZMZTesting
//
//  Created by 강준영 on 10/23/25.
//  Copyright © 2025 Junyoung. All rights reserved.
//

import Foundation
import Domain

public final class MockFindLocationUseCase: FindLocationUseCaseProtocol, TestDouble {
    public func findLocation(location: String) async throws -> [SearchLocationEntity] {
        self.resolve([SearchLocationEntity].self, name: "findLocation") ?? []
    }
}
