//
//  MZMZWidzetBundle.swift
//  MZMZWidzet
//
//  Created by 강준영 on 2025/04/16.
//

import WidgetKit
import SwiftUI
import Repository

@main
struct MZMZWidzetBundle: WidgetBundle {
    init() {
        // 익스텐션은 AppDelegate 가 돌지 않아 여기서 직접 초기화한다.
        AppCheckBootstrap.configure()
    }

    var body: some Widget {
        MZMZWidzet() // 잠금 화면 위젯
//        MZMZWidzetLiveActivity() //홈화면 위젯
    }
}
