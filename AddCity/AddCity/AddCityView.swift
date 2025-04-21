//
//  AddCityView.swift
//  AddCity
//
//  Created by 강준영 on 2025/04/21.
//

import SwiftUI

public struct AddCityView: View {
    @State private var textedCity: String = ""
    @FocusState private var isSearchFocus: Bool
    
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
                    TextField("도시 검색", text: $textedCity)
                        .focused($isSearchFocus)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button("Cancel") {
                        
                    }
                }
                .padding(20)
                
                Spacer()
            }
        }
    }
}
