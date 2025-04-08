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
        NavigationView {
            ScrollView {
                VStack {
                    List(self.dustListModel) { dataModel in
                        listView(dataModel)
                            .listRowSeparator(.hidden)
                    }
                    .background(Color.yellow)
                    .listStyle(.inset)
                }
            }
            .navigationTitle("미세먼지")
            .searchable(text: $searchCity, prompt: "도시 검색")
            .onReceive(viewModel.dustListStream) { dustList in
                self.dustListModel = dustList
                print(dustList)
            }
        }
    }
    
    public func listView(_ dataModel: DustListViewDataModel) -> some View {
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
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
    }
}


