//
//  DustListViewDataModel.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/16.
//

import Foundation
import Domain

final class DustListViewDataModel: Identifiable {
    let location: String
    let dust: String
    let microDust: String
    
    init(_ entity: DustEntity) {
        self.location = entity.location
        self.dust = entity.dust
        self.microDust = entity.microDust
    }
}
