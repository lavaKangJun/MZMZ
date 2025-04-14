//
//  DustListView.swift
//  DustListView
//
//  Created by 강준영 on 2025/03/29.
//

import SwiftUI

public struct DustListView: View {
    private let viewModel: DustListViewModel
    @State private var dustListModel: [DustListViewDataModel] = []
    @State private var searchCity = ""
    
    public init(viewModel: DustListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        SearchNavigationWrapper(searchText: $searchCity) {
            List(self.dustListModel) { dataModel in
                listView(dataModel)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .onReceive(viewModel.dustListStream) { dustList in
            self.dustListModel = dustList
        }
    }
    
    public func listView(_ dataModel: DustListViewDataModel) -> some View {
        ZStack {
            Color.clear
                .background(
                    Image("sunny", bundle: Bundle.current)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .alignmentGuide(.top) { d in d[.top] }
                )
                .mask(RoundedRectangle(cornerRadius: 10))
            
            HStack(alignment: .top) {
                Text(dataModel.location)
                    .font(.headline)
                
                HStack {
                    Text("미세먼지: ")
                        .font(.title3)
                    Text(dataModel.dustGrade ?? "")
                        .font(.body)
                }
                
                HStack {
                    Text("초미세먼지: ")
                        .font(.title3)
                    Text(dataModel.microDustGrade ?? "")
                        .font(.body)
                }
                
                Spacer()
            }
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .cornerRadius(10)
        .clipped()
    }
}

class BundleFinder {}
extension Bundle {
    static var current: Bundle {
        return Bundle(for: BundleFinder.self)
    }
}
