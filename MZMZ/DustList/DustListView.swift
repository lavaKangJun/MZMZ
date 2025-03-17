//
//  DustListView.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/16.
//

import SwiftUI

struct DustListView: View {
    private let viewModel: DustListViewModel
    
    init(viewModel: DustListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("미세먼지")
                .font(Font.system(size: 30, weight: .bold))
                .fontWeight(.bold)
                
            List(viewModel.fetchDust()) { dataModel in
                listView(dataModel)
                    .listRowSeparator(.hidden)
            }
            .background(Color.yellow)
            .listStyle(.inset)
        }
    }
    
    func listView(_ dataModel: DustListViewDataModel) -> some View {
        HStack(alignment: .top) {
            Text(dataModel.location)
                .font(.headline)
            
            Text(dataModel.dust)
                .font(.body)
            
            Text(dataModel.microDust)
                .font(.body)
            
            Spacer()
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
    }
}


