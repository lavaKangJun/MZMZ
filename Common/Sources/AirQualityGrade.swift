//
//  AirQualityGrade.swift
//  AirQualityGrade
//
//  Created by 강준영 on 2026/05/03.
//

import SwiftUI

public enum AirQualityGrade: String {
    case checking = "점검중"
    case good = "좋음"
    case moderate = "보통"
    case caution = "주의"
    case bad = "나쁨"
    case veryBad = "매우나쁨"
}

extension AirQualityGrade {
    public static func grade(forPM10: String) -> AirQualityGrade {
        guard let value = Int(forPM10) else { return .checking }
        switch value {
        case 0...45:
            return .good
        case 46...50:
            return .moderate
        case 51...75:
            return .caution
        case 76...100:
            return .bad
        case 101...:
            return .veryBad
        default:
            return .checking // 점검중: -1
        }
    }
    
    public static func grade(forPM25: String) -> AirQualityGrade {
        guard let value = Int(forPM25) else { return .checking }
        switch value {
        case 0...15:
            return .good
        case 16...25:
            return .moderate
        case 26...37:
            return .caution
        case 38...50:
            return .bad
        case 51...:
            return .veryBad
        default:
            return .checking // 점검중: -1
        }
    }
    
    public func gradientColors(isDark: Bool) -> Color {
        switch self {
        case .good:
            return isDark ? Color(hex: "3a6a95") : Color(hex: "9ed0ea")
        case .moderate:
            return isDark ? Color(hex: "4a7a68") : Color(hex: "a8d0bd")
        case .caution:
            return isDark ? Color(hex: "b09545") : Color(hex: "ecce6a")
        case .bad:
            return isDark ? Color(hex: "a87038") : Color(hex: "dc9565")
        case .veryBad:
            return Color(hex: "5a3422")
        case .checking:
            return isDark ? Color(hex: "525258") : Color(hex: "b0b0b4")
        }
    }
    
    public var severity: Int {
        switch self {
        case .good: return 0
        case .moderate: return 1
        case .caution: return 2
        case .bad: return 3
        case .veryBad: return 4
        case .checking: return -1
        }
    }
}


public struct AirQualityCardBackground: View {
    private let pm10Grade: AirQualityGrade
    private let pm25Grade: AirQualityGrade
    @Environment(\.colorScheme) private var colorScheme
    
    public init(pm10Grade: AirQualityGrade, pm25Grade: AirQualityGrade) {
        self.pm10Grade = pm10Grade
        self.pm25Grade = pm25Grade
    }
    
    public var body: some View {
        ZStack {
            if pm10Grade == pm25Grade {
                leftColor
            } else {
                LinearGradient(
                    stops: [
                        .init(color: leftColor, location: 0.0),
                        .init(color: leftColor, location: 0.4),
                        .init(color: rightColor, location: 0.6),
                        .init(color: rightColor, location: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            // 입자 (주의 이상)
            if pm10Grade.severity >= 2 {
                DustParticles(count: particleCount(for: pm10Grade), side: .left)
            }
            if pm25Grade.severity >= 2 {
                DustParticles(count: particleCount(for: pm25Grade), side: .right)
            }
            
            // 햇살 (양쪽 다 좋음)
            if pm10Grade == .good && pm25Grade == .good {
                SunOverlay()
            }
        }
    }
    
    // MARK: - 좌상단 → 우하단 대각선으로 좌측 영역만 그리기
    private struct LeftDiagonalShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            // 좌상단(0,0) → 우상단 60% 지점 → 좌하단 40% 지점 → 좌하단(0,h)
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width * 0.6, y: 0))
            path.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
            return path
        }
    }
    
    private func particleCount(for grade: AirQualityGrade) -> Int {
        switch grade {
        case .caution: return 2
        case .bad: return 3
        case .veryBad: return 5
        default: return 0
        }
    }
    
    /// 좌측 색 (미세먼지 등급의 어두운 톤)
    private var leftColor: Color {
        pm10Grade.gradientColors(isDark: colorScheme == .dark)
    }
    
    /// 우측 색 (초미세 등급의 밝은 톤)
    private var rightColor: Color {
        pm25Grade.gradientColors(isDark: colorScheme == .dark)
    }
}

private struct SunOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "ffd966").opacity(0.6),
                            Color(hex: "ffd966").opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .position(x: geo.size.width - 30, y: 30)
        }
    }
}



// MARK: - 먼지 입자
private struct DustParticles: View {
    enum Side { case left, right }
    
    let count: Int
    let side: Side
    
    @State private var positions: [CGPoint] = []
    
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: CGFloat.random(in: 2...4),
                           height: CGFloat.random(in: 2...4))
                    .position(
                        x: positions.indices.contains(i)
                        ? positions[i].x * geo.size.width
                        : 0.5 * geo.size.width,
                        y: positions.indices.contains(i)
                        ? positions[i].y * geo.size.height
                        : 0.5 * geo.size.height
                    )
            }
            .onAppear {
                if positions.isEmpty {
                    positions = (0..<count).map { _ in
                        let xRange: ClosedRange<CGFloat> = side == .left
                        ? 0.05...0.35
                        : 0.65...0.95
                        return CGPoint(
                            x: CGFloat.random(in: xRange),
                            y: CGFloat.random(in: 0.15...0.85)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Color Hex
extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
