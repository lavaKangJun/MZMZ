//
//  TestHelper.swift
//  MZMZTesting
//
//  Created by 강준영 on 10/23/25.
//  Copyright © 2025 Junyoung. All rights reserved.
//

import Foundation

nonisolated(unsafe) private var containerKey = "container"

public protocol TestDouble {
    func called(name: String, verify: @escaping (Any) -> Void)
    func verify(name: String, args: Any?)
    func register<Object>(_ type: Object.Type, name: String, provider: @escaping () -> Object)
    func resolve<Object>(_ type: Object.Type, name: String) -> Object?
}

extension TestDouble {
    //        objc_setAssociatedObject(
    //            self,          // ← 이 객체에
    //            &containerKey, // ← 이 키로
    //            container,     // ← 이 값을
    //            policy
    //        )
    //
    
    private var container: DIContainer {
        if let value = objc_getAssociatedObject(self, &containerKey) as? DIContainer {
            return value
        } else {
            let container = DIContainer()
            objc_setAssociatedObject(self, &containerKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return container
        }
    }
    
    func register<Object>(_ type: Object.Type, name: String, provider: @escaping () -> Object) {
        self.container.register(type, name: name, provider: provider)
    }
    
    func resolve<Object>(_ type: Object.Type, name: String) -> Object? {
        self.container.resolve(type, name: name)
    }
    
    public func called(name: String, verify: @escaping (Any) -> Void) {
        self.container.called(name: name, verify: verify)
    }
    
    public func verify(name: String, args: Any?) {
        self.container.verify(name: name, args: args)
    }
}


final class DIContainer {
    typealias Verify = (Any?) -> Void
    typealias Provier = () -> Any
    private var verifyContainer: [String: Verify] = [:]
    private var providerContainer: [String: Provier] = [:]
    
    func register<Object>(_ type: Object.Type, name: String, provider: @escaping () -> Object) {
        self.providerContainer[name] = provider
    }
    
    func resolve<Object>(_ type: Object.Type, name: String) -> Object? {
        let provider = providerContainer[name]
        let value = provider?()
        return value as? Object
    }
    
    func called(name: String, verify: @escaping (Any) -> Void) {
        self.verifyContainer[name] = verify
    }
    
    func verify(name: String, args: Any?) {
        let verify = self.verifyContainer[name]
        verify?(args)
    }
}
