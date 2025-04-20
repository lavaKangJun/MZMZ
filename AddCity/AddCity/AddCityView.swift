//
//  AddCityView.swift
//  AddCity
//
//  Created by 강준영 on 2025/04/21.
//

import SwiftUI

public struct AddCityView: View {
    @State private var textedCity: String = ""
    
    public var body: some View {
        VStack {
            HStack {
                TextField("도시 검색", text: $textedCity)
            }
        }
    }
}
