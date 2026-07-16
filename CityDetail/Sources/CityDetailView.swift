//
//  CityDetailView.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import SwiftUI
import Common

public struct CityDetailView: View {
    @ObservedObject private var viewModel: CityDetailViewModel
    
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
            
            Text(currentTimeText)
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
        case .bad, .veryBad: return "facemask.fill"
        case .checking: return "questionmark.circle.fill"
        }
    }
    
    private var currentTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
    
    private func dustText(_ dataMode: CityDetailViewDataModel) -> String {
        let pm10 = dataMode.dustDensity
        return pm10 == "-1" ? "-" : "\(pm10) ㎍/㎥"
    }
    
    private func microDustText(_ dataMode: CityDetailViewDataModel) -> String {
        let pm25 = dataMode.microDustDensity
        return pm25 == "-1" ? "-" : "\(pm25) ㎍/㎥"
    }
}
