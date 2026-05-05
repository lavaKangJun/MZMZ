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
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
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
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    
                    Button("Cancel") {
                        textedCity = ""
                        viewModel.clearSearch()
                    }
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 10, trailing: 20))
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.cityCellViewModel, id: \.name) { cellViewModel in
                            SearchResultRow(fullName: cellViewModel.name, query: textedCity) {
                                let dependecvy = CityDetailDependency(
                                    name: cellViewModel.name,
                                    station: nil,
                                    longitude: cellViewModel.longitude,
                                    latitude: cellViewModel.latitude,
                                    isSearchResult: true
                                )
                                viewModel.routeToCityDetail(dependecvy)
                            }
                        }
                    }
                }
            }
            .onChange(of: textedCity) { oldValue, newValue in
                if newValue.isEmpty == false, oldValue != newValue {
                    viewModel.searchText(newValue)
                }
            }
        }
    }
}


struct SearchResultRow: View {
    let fullName: String
    let query: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                highlightedText
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    /// 검색어 매칭 부분 강조
    private var highlightedText: Text {
        guard !query.isEmpty,
              let range = fullName.range(of: query) else {
            return Text(fullName)
        }
        
        let before = String(fullName[..<range.lowerBound])
        let match = String(fullName[range])
        let after = String(fullName[range.upperBound...])
        
        return Text(before) +
               Text(match).foregroundStyle(.blue).bold() +
               Text(after)
    }
}
