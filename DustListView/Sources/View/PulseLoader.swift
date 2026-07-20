//
//  PulseLoader.swift
//  DustListView
//
//  Created by 강준영 on 7/20/26.
//  Copyright © 2026 Junyoung. All rights reserved.
//
import SwiftUI

struct PulseLoader: View {
    @State private var scale = 0.6
    @State private var opacity = 1.0
    
    var body: some View {
        Circle()
            .fill(Color(hex: "9ed0ea"))
            .frame(width: 50, height: 50)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    scale = 1.3
                    opacity = 0.0
                }
            }
    }
}
