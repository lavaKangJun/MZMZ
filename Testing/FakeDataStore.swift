//
//  FakeDataStore.swift
//  Testing
//
//  Created by 강준영 on 2025/05/11.
//

import Foundation
import Repository

public final class FakeDataStore: DataStorable {
    public static let shared = FakeDataStore()
    private var dustInfos: [DustStoreDTO] = [
        DustStoreDTO(
            location: "풍납2동",
            longitude: "127.115731280691",
            latitude: "37.529239225114"
        ),
        DustStoreDTO(
            location: "역삼2동",
            longitude: "127.033201088112",
            latitude: "37.4954279212045"
        ),
    ]
    
    private init() { }
    
    public func getDustInfo() -> [DustStoreDTO] {
        return dustInfos
    }
    
    public func setDustInfo(_ info: DustStoreDTO) {
        self.dustInfos.append(info)
    }
    
    public func insertTable(data: DustStoreDTO) throws {
        
    }
    
    public func load() throws -> [DustStoreDTO] {
        return []
    }
    
    public func delete(location: String) throws -> Bool {
        return false
    }
}
