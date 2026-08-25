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
//        Circle()
//            .fill(Color(hex: "9ed0ea"))
//            .frame(width: 50, height: 50)
//            .scaleEffect(scale)
//            .opacity(opacity)
//            .onAppear {
//                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
//                    scale = 1.3
//                    opacity = 0.0
//                }
//            }
        
        ZStack {
            
                    Image("dust_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150) // 로고 최종 크기
                        .scaleEffect(scale) // 크기에 바운스 효과 적용
                        .onAppear {
                            // 통통 튀는 스프링 애니메이션 적용
                            withAnimation(
                                .interpolatingSpring(stiffness: 170, damping: 10) // stiffness(경도), damping(마찰력) 조절로 탄성 변경 가능
                            ) {
                                scale = 1.0 // 최종 크기 (1.0배)
                            }
                        }
                }
    }
}
