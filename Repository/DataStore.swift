//
//  DataStore.swift
//  Repository
//
//  Created by 강준영 on 2025/05/08.
//

import Foundation

public final class DataStore {
    public static let shared = DataStore()
    private var dustInfos: [DustStoreDTO] = []
    
    private init() { }
    
    public func getDustInfo() -> [DustStoreDTO] {
        return dustInfos
    }
     
    public func setDustInfo(_ info: DustStoreDTO) {
        self.dustInfos.append(info)
        print(self.dustInfos)
    }
}
