//
//  DustListView.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import SwiftUI
import Common

public struct DustListView: View {
    private let viewModel: DustListViewModel
    @State private var dustListModel: [DustListViewDataModel] = []
    @State private var searchCity = ""
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    
    public init(viewModel: DustListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(Color(.systemGray6))
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Group {
                        HStack {
                            Text("즐겨찾기로 추가한 지역을 위젯으로 볼 수 있습니다.")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, -10)
                        
                        List {
                            ForEach(self.dustListModel, id: \.self) { dataModel in
                                listView(dataModel)
                                    .padding(.bottom, 20)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                        Button(role: .destructive) {
                                            viewModel.deleteLocation(dataModel.location)
                                        } label: {
                                            Label("삭제", systemImage: "trash")
                                        }
                                        .tint(.clear)
                                    })
                                    .onTapGesture {
                                        self.viewModel
                                            .routeToDetail(
                                                name: dataModel.location,
                                                station: dataModel.station,
                                                longitude: dataModel.longtitude,
                                                latitude: dataModel.latitude
                                            )
                                    }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        Spacer()
                        
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .font(.largeTitle)
                            .onTapGesture {
                                viewModel.routeToFindLocation()
                            }
                        
                        HStack(spacing: 3) {
                            Text("※")
                                .baselineOffset(2)
                            Text("미세먼지 등급은 WHO 기준으로 표시됩니다.")
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                    .navigationTitle("미세먼지")
                    .navigationBarTitleDisplayMode(.large)
                }
                .onReceive(viewModel.dustListStream) { dustList in
                    self.dustListModel = dustList
                }
                .onReceive(viewModel.errorStream) { message in
                    self.errorMessage = message
                    self.showErrorAlert = true
                }
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("fetch error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("확인"))
                    )
                }
                .onViewWillAppear {
                    viewModel.fetchDust()
                }
            }
        }
    }
    
    public func listView(_ dataModel: DustListViewDataModel) -> some View {
        ZStack(alignment: .leading) {
            AirQualityCardBackground(
                pm10Grade: dataModel.dustGrade,
                pm25Grade: dataModel.microDustGrade,
                style: .list
            )
                .mask(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(dataModel.location)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                    
                    if dataModel.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                }
                HStack(alignment: .bottom, spacing: 0) {
                    GradeColumn(
                        label: "미세",
                        grade: dataModel.dustGrade,
                        value: dataModel.dustDensity,
                        alignment: .leading
                    )
                    
                    Spacer()
                    
                    GradeColumn(
                        label: "초미세",
                        grade: dataModel.microDustGrade,
                        value: dataModel.microDustDensity,
                        alignment: .trailing
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private struct GradeColumn: View {
        let label: String
        let grade: AirQualityGrade
        let value: String?
        let alignment: HorizontalAlignment
        
        /// "매우나쁨"(4자)만 사이즈 줄이기
        private var gradeFontSize: CGFloat {
            grade == .veryBad ? 18 : 22
        }
        
        /// 점검중이면 "—", 그 외엔 수치 표시
        private var valueText: String {
            guard let value, grade != .checking else { return "—" }
            return "\(value) ㎍/㎥"
        }
        
        var body: some View {
            VStack(alignment: alignment, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(0.3)
                
                Text(grade.rawValue)
                    .font(.system(size: gradeFontSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.top, -2)
                
                Text(valueText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 2)
            }
        }
    }
}
