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
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    
    public init(viewModel: DustListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            Spacer()
            
            Group {
                List {
                    ForEach(self.dustListModel, id: \.self) { dataModel in
                        listView(dataModel)
                            .padding(.bottom, 20)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false, content: {
                                Button(role: .destructive) {
                                    viewModel.deleteLocation(dataModel.location)
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                                .tint(.clear)
                            })
                            .onTapGesture {
                                self.viewModel.routeToDetail(name: dataModel.location, longitude: dataModel.longtitude, latitude: dataModel.latitude)
                            }
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .imageScale(.large)
                    .font(.largeTitle)
                    .onTapGesture {
                        viewModel.routeToFindLocation()
                    }
                
                Spacer()
                    .frame(height: 40)
            }
            .navigationTitle("미세먼지")
            .navigationBarTitleDisplayMode(.large)
        }
        .background(Color.white)
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
    
    public func listView(_ dataModel: DustListViewDataModel) -> some View {
        ZStack(alignment: .leading) {
            Color.clear
                .background(
                    LinearGradient(gradient: Gradient(colors: dataModel.backgroundColor),
                                   startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                )
                .mask(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Spacer()
                
                Text(dataModel.location)
                    .font(Font.system(size: 20, weight: .bold))
                    .foregroundColor(Color.white)
                
                Spacer()
                
                HStack {
                    HStack {
                        Text("미세먼지:")
                        Text(dataModel.dustGradeText + " " + "\(dataModel.dustDensity) μg/m3")
                        
                    }
                    .foregroundColor(Color.gray)
                    .font(Font.system(size: 13, weight: .semibold))
                    
                    HStack {
                        Text("초미세먼지:")
                        Text(dataModel.microDustGradeText + " " + "\(dataModel.microDustDensity) μg/m3")
                    }.foregroundColor(Color.gray)
                        .font(Font.system(size: 13, weight: .semibold))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
        .clipped()
    }
}

class BundleFinder {}
extension Bundle {
    static var current: Bundle {
        return Bundle(for: BundleFinder.self)
    }
}
