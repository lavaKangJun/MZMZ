//
//  Extension.swift
//  DustListView
//
//  Created by 강준영 on 2025/05/10.
//

import UIKit
import SwiftUI

struct ViewWillAppearModifier: UIViewControllerRepresentable {
    let onViewWillAppear: () -> Void
    
    func makeUIViewController(context: Context) -> some UIViewController {
        WrapperViewController(onViewWillAppear: onViewWillAppear)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class WrapperViewController: UIViewController {
        let onViewWillAppear: () -> Void
        
        init(onViewWillAppear: @escaping () -> Void) {
            self.onViewWillAppear = onViewWillAppear
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            onViewWillAppear()
        }
    }
}

extension View {
    func onViewWillAppear(perform: @escaping () -> Void) -> some View {
        self.background(
            ViewWillAppearModifier(onViewWillAppear: perform)
                .frame(width: 0, height: 0)
        )
    }
}

