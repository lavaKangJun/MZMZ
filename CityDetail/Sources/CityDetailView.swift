//
//  CityDetailView.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import SwiftUI
import Common

public struct CityDetailView: View {
    public var viewModel: CityDetailViewModel
    
    init(viewModel: CityDetailViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            AirQualityCardBackground(
                pm10Grade: viewModel.dataModel.dustGrade,
                pm25Grade: viewModel.dataModel.microDustGrade,
                style: .detail
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: viewModel.loadState)
            
            VStack(spacing: 0) {
                // 상단 영역
                headerSection(viewModel.dataModel)
                
                Group {
                    // 큰 등급 표시
                    mainGradeSection(viewModel.dataModel)
                        .padding(.top, 24)
                    
                    // 안내 메시지
                    gradeDescription(viewModel.dataModel)
                        .padding(.top, 28)
                        .padding(.horizontal, 20)
                    
                    // 측정소 정보
                    observatoryView(viewModel.dataModel)
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                }
                .redacted(reason: viewModel.loadState == .loading ? .placeholder : [])
                
                if viewModel.loadState == .loading {
                    VStack() {
                        Spacer()
                            .frame(height: 30)
                        Text("데이터를 가져오고 있습니다...")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .transition(.opacity)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.top, 140)
            
            // 상단 네비게이션 (오버레이)
            VStack {
                topNavigationBar(isSearched: viewModel.isSearched, isFavorite: viewModel.dataModel.isFavorite)
                Spacer()
            }
        }
        .onDisappear {
            viewModel.disappear()
        }
    }
    
    private func topNavigationBar(isSearched: Bool, isFavorite: Bool) -> some View {
        HStack {
            Spacer()
            if isSearched {
                Button("추가") {
                    self.viewModel.saveCity()
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            } else {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isFavorite ? Color(hex: "ffd966") : .white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private func headerSection(_ dataModel: CityDetailViewDataModel) -> some View {
        VStack(spacing: 6) {
            Text(dataModel.location)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Text(measuredAtText(dataModel))
                .font(.system(size: 17))
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.top, 80)
    }
    
    private func mainGradeSection(_ dataModel: CityDetailViewDataModel) -> some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                // 미세
                Text("미세")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(0.5)
                
                Text(dataModel.dustGrade.rawValue)
                    .font(.system(
                        size: dataModel.dustGrade == .veryBad ? 36 : 44,
                        weight: .light
                    ))
                    .foregroundStyle(.white)
                
                Text(dustText(dataModel))
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.85))
            }.frame(maxWidth: .infinity)
            
            // 구분선
            Rectangle()
                .fill(.white.opacity(0.25))
                .frame(width: 1, height: 80)
            
            // 초미세
            VStack(spacing: 4) {
                Text("초미세")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(0.5)
                
                Text(dataModel.microDustGrade.rawValue)
                    .font(.system(
                        size: dataModel.microDustGrade == .veryBad ? 36 : 44,
                        weight: .light
                    ))
                    .foregroundStyle(.white)
                
                Text(microDustText(dataModel))
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }
    
    private func gradeDescription(_ dataModel: CityDetailViewDataModel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: advisoryIcon(dataModel))
                .font(.system(size: 20))
                .foregroundStyle(.white)
            
            Text(worstGrade(dataModel).description)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.95))
                .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    // MARK: - 측정소 정보
    private func observatoryView(_ dataModel: CityDetailViewDataModel) -> some View {
        HStack {
            Image(systemName: "location.fill")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.8))
            
            Text("관측소")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
            
            Spacer()
            
            Text(dataModel.station ?? "-")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    /// 둘 중 더 나쁜 등급 기준으로 안내
    private func worstGrade(_ dataModel: CityDetailViewDataModel) -> AirQualityGrade {
        let dust = dataModel.dustGrade
        let microDust = dataModel.microDustGrade
        return dust.severity > microDust.severity ? dust : microDust
    }

    private func advisoryIcon(_ dataModel: CityDetailViewDataModel) -> String {
        switch worstGrade(dataModel) {
        case .good: return "sun.max.fill"
        case .moderate: return "cloud.sun.fill"
        case .caution: return "exclamationmark.circle.fill"
        case .bad, .veryBad, .extreme: return "facemask.fill"
        case .checking: return "questionmark.circle.fill"
        }
    }
    
    /// 측정 시각 표시.
    ///
    /// 예전에는 `Date()` 로 화면을 여는 시각을 보여줬는데, 그건 "언제 잰
    /// 값인지"와 무관하다. 에어코리아는 매시 정시 값을 :14 무렵에 올리므로
    /// 실제 측정 시각은 현재 시각보다 최대 한 시간 넘게 이전일 수 있다.
    ///
    /// 서버가 주는 dataTime("yyyy-MM-dd HH:mm", KST)을 그대로 쓴다.
    /// 값이 없으면(측정소 점검 등) 농도 표시와 같은 "—" 로 맞춘다.
    private func measuredAtText(_ dataModel: CityDetailViewDataModel) -> String {
        guard let dataTime = dataModel.dataTime,
              let date = Self.serverFormatter.date(from: dataTime) else {
            return "—"
        }
        return Self.displayFormatter.string(from: date) + " 기준"
    }

    /// 서버 원문 파싱용. 고정 형식이라 en_US_POSIX 를 쓴다.
    /// (사용자 달력 설정이 불교력 등이면 ko_KR 로는 파싱이 깨진다)
    private static let serverFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    /// 화면 표시용.
    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "M월 d일 HH:mm"
        return formatter
    }()
    
    private func dustText(_ dataMode: CityDetailViewDataModel) -> String {
        let pm10 = dataMode.dustDensity
        return pm10 == "-1" ? "-" : "\(pm10) ㎍/㎥"
    }
    
    private func microDustText(_ dataMode: CityDetailViewDataModel) -> String {
        let pm25 = dataMode.microDustDensity
        return pm25 == "-1" ? "-" : "\(pm25) ㎍/㎥"
    }
}
