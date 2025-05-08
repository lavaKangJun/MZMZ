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
            VStack {
                if let dataModel = viewModel.dataModel {
                    Text(dataModel.location)
                        .font(.headline)
                    HStack {
                        Text("미세먼지")
                        Text(dataModel.dustGradeText)
                    }
                    HStack {
                        Text("초미세먼지")
                        Text(dataModel.microDustGradeText)
                    }
                }
            }
            
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
        .onAppear {
            viewModel.fetchCurrentCityDustInfo()
        }
    }
}
