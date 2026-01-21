//
//  CityDetailView.swift
//  CityDetail
//
//  Created by 강준영 on 2025/05/01.
//

import SwiftUI

public struct CityDetailView: View {
    @StateObject private var viewModel: CityDetailViewModel
    
    init(viewModel: CityDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            backgroundView
                .ignoresSafeArea()
            VStack(spacing: 10) {
                if let dataModel = viewModel.dataModel {
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
                        Text(dataModel.dustGradeText)
                        Text(dataModel.dustDensity + " μg/m3")
                    }
                    .font(.system(size: 20, weight: .medium))
                    
                    HStack {
                        Image("microdust", bundle: Bundle.module)
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        Text("초미세먼지")
                        Text(dataModel.microDustGradeText)
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
    
    private var backgroundView: some View {
        if let colors = viewModel.dataModel?.backgroundColor {
            return LinearGradient(gradient: Gradient(colors: colors),
                                  startPoint: .top,
                                  endPoint: .bottom)
        } else {
            return LinearGradient(gradient: Gradient(colors: []),
                                  startPoint: .top, endPoint: .bottom)
        }
    }
}
