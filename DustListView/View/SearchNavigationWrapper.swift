//
//  SearchNavigationWrapper.swift
//  DustListView
//
//  Created by 강준영 on 2025/04/11.
//

import SwiftUI

public struct SearchNavigationWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding private var searchText: String
    private let content: () -> Content
    
    public init(searchText: Binding<String>, content: @escaping () -> Content) {
        self._searchText = searchText
        self.content = content
    }
    
    public func makeUIViewController(context: Context) -> UINavigationController {
        let hosting = UIHostingController(rootView: content())
        let navigationVC = UINavigationController(rootViewController: hosting)
        
        let searchController = UISearchController(searchResultsController: nil)
        // UIKit의 검색 컨트롤러 생성, 업데이트 이벤트를 SwiftUI와 연결하려고 Coordinator 연결
        searchController.searchResultsUpdater = context.coordinator
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "도시 검색"
        
        hosting.navigationItem.searchController = searchController
        hosting.navigationItem.hidesSearchBarWhenScrolling = false
        hosting.view.backgroundColor = .clear
        
        navigationVC.navigationBar.prefersLargeTitles = true
        navigationVC.topViewController?.title = "미세먼지"
        
        return navigationVC
    }
    
    // SwiftUI에서 상태가 바뀌면 여기로 알려줌
    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        if let hosting = uiViewController.topViewController as? UIHostingController<Content> {
            // 상태 바뀌면 다시 엎어침
            hosting.rootView = content()
        }
    }
    
    // UIKit의 이벤트를 SwiftUI에 전달하기위해 Coordinator를 씀
    public func makeCoordinator() -> Coordinator {
        return Coordinator(searchText: $searchText)
    }
    
    // UIKit → SwiftUI로 데이터를 전달
    // 사용자가 UISearchController에 텍스트를 입력하면, 이 함수가 호출되고 @Binding var searchText에 연결된 값이 자동 업데이트됨
    public class Coordinator: NSObject, UISearchResultsUpdating {
        @Binding private var searchText: String
        
        init(searchText: Binding<String>) {
            self._searchText = searchText
        }
        
        public func updateSearchResults(for searchController: UISearchController) {
            searchText = searchController.searchBar.text ?? ""
        }
    }
}
