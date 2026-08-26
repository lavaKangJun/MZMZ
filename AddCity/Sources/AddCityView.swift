//
//  AddCityView.swift
//  AddCity
//
//  Created by 강준영 on 2025/04/21.
//

import SwiftUI
import UIKit
import Scene

public struct AddCityView: View {
    /// 리스트 화면은 플러스 버튼 아래에 caption2 안내 문구 한 줄(+ 위 여백 10)과
    /// 40pt 여백이 있다. 이 화면엔 안내 문구가 없으므로 그만큼을 여백으로 더해
    /// 두 화면의 버튼이 같은 높이에 오게 한다. 글꼴 크기 설정을 따라간다.
    private static var bottomInset: CGFloat {
        UIFont.preferredFont(forTextStyle: .caption2).lineHeight + 10 + 40
    }
    
    /// 닫기 버튼이 차지하는 높이. 검색 결과가 버튼에 가리지 않도록
    /// 목록 아래에 같은 크기의 자리를 비워 두는 데 쓴다.
    private static var closeButtonHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .largeTitle).lineHeight
    }
    
    @State private var textedCity: String = ""
    @FocusState private var isSearchFocus: Bool
    public let viewModel: AddCityViewModel
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("지역 추가")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)
                    
                    
                    HStack {
                        Text("추가한 지역은 리스트 화면에서 볼 수 있습니다.")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, -10)
                    
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
                        
                        Button("취소") {
                            textedCity = ""
                            viewModel.claer()
                        }
                        .tint(Color(.gray))
                    }
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 10, trailing: 20))
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.cityCellViewModels, id: \.name) { cellViewModel in
                                SearchResultRow(fullName: cellViewModel.name, query: textedCity) {
                                    let dependecvy =
                                    CityDetailDependency(
                                        name: cellViewModel.name,
                                        longitude: cellViewModel.longitude,
                                        latitude: cellViewModel.latitude
                                    )
                                    viewModel.routeToCityDetail(dependecvy)
                                }
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    
                    // 아래 고정된 닫기 버튼과 결과 목록이 겹치지 않도록
                    // 그만큼 자리를 비워 둔다.
                    Spacer()
                        .frame(height: Self.closeButtonHeight + Self.bottomInset)
                }
                .onChange(of: textedCity) { oldValue, newValue in
                    if newValue.isEmpty == false, oldValue != newValue {
                        viewModel.searchText(newValue)
                    }
                }
                
                // 닫기 버튼만 키보드를 무시해 제자리에 둔다. 검색 결과 목록은
                // 위 VStack 에 남아 있어 평소대로 키보드를 피해 올라온다.
                VStack {
                    Spacer()
                    
                    Image(systemName: "multiply.circle")
                        .imageScale(.large)
                        .font(.largeTitle)
                        .onTapGesture {
                            isSearchFocus = false
                            viewModel.dismiss()
                        }
                    
                    Spacer()
                        .frame(height: Self.bottomInset)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            // 빈 곳을 탭하면 키보드를 내린다. 자식(검색 결과 행, 닫기 버튼)이
            // 먼저 탭을 가져가고, 아무도 안 받은 탭만 여기로 온다.
            // ZStack 에 걸어야 위에 뭘 더 얹어도 계속 동작한다.
            .contentShape(Rectangle())
            .onTapGesture {
                isSearchFocus = false
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
