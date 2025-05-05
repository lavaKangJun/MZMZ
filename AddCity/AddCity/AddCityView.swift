//
//  AddCityView.swift
//  AddCity
//
//  Created by 강준영 on 2025/04/21.
//

import SwiftUI
import Scene

public struct AddCityView: View {
    @State private var textedCity: String = ""
    @FocusState private var isSearchFocus: Bool
    @StateObject private var viewModel: AddCityViewModel
    
    init(viewModel: AddCityViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    isSearchFocus = false
                }
            
            VStack {
                Spacer()
                    .frame(height: 20)
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("도시 검색", text: $textedCity)
                            .focused($isSearchFocus)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Button("Cancel") {
                        textedCity = ""
                        viewModel.clearSearch()
                    }
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 10, trailing: 20))
                
                List(viewModel.cityCellViewModel, id: \.name) { cellViewModel in
                    Text(cellViewModel.name)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            let dependecvy = CityDetailDependency(
                                name: cellViewModel.name,
                                longitude: cellViewModel.longitude,
                                latitude: cellViewModel.latitude,
                                isSearchResult: true
                            )
                            viewModel.routeToCityDetail(dependecvy)
                        }
                }
                .listStyle(.plain)
            }
            .onChange(of: textedCity) { oldValue, newValue in
                if newValue.isEmpty == false, oldValue != newValue {
                    viewModel.searchText(newValue)
                }
            }
        }
    }
}
