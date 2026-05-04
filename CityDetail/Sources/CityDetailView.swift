//
//  CityDetailView.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import SwiftUI
import Common

public struct CityDetailView: View {
    @StateObject private var viewModel: CityDetailViewModel
    
    init(viewModel: CityDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            AirQualityCardBackground(pm10Grade: viewModel.dataModel?.dustGrade ?? .checking, pm25Grade: viewModel.dataModel?.microDustGrade ?? .checking)
                .ignoresSafeArea()
            VStack(spacing: 10) {
                if let dataModel = viewModel.dataModel {
                    HStack {
                        Image(systemName: dataModel.isFavorite ? "star.fill" : "star")
                            .font(.system(size: 25, weight: .light))
                            .foregroundColor(.white)
                            .onTapGesture {
                                viewModel.toggleFavorite()
                            }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                   
                    Spacer()
                    
                    Text(dataModel.location)
                        .font(.system(size: 30, weight: .bold))

                    Spacer()
                        .frame(height: 50)
                    
                    HStack {
                        Image("dust", bundle: Bundle.module)
                            .resizable()
                            .frame(width: 40, height: 40)
                       
                        Text("미세먼지")
                        Text(dataModel.dustGrade.rawValue)
                        Text(dataModel.dustDensity + " μg/m3")
                    }
                    .font(.system(size: 20, weight: .medium))
                    
                    HStack {
                        Image("microdust", bundle: Bundle.module)
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        Text("초미세먼지")
                        Text(dataModel.microDustGrade.rawValue)
                        Text(dataModel.microDustDensity + " μg/m3")
                    }
                    .font(.system(size: 20, weight: .medium))
                    
                    Spacer()
                    
                    Text("관측소: \(dataModel.station ?? "")")
                    
                    Spacer()
                }
            }
            .foregroundColor(.white)
            
            if viewModel.isSearched {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button("추가") {
                            self.viewModel.saveCity()
                        }
                        
                        Spacer()
                            .frame(width: 16)
                    }
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            viewModel.fetchCurrentCityDustInfo()
        }
    }
}
