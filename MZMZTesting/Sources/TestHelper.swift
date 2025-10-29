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
    func registerWithThrows<Object>(_ type: Object.Type, name: String, provider: @escaping () throws -> Object)
    func resolveWithThrows<Object>(_ type: Object.Type, name: String) throws -> Object?
    
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
    
    public func registerWithThrows<Object>(_ type: Object.Type, name: String, provider: @escaping () throws -> Object) {
        self.container.registerWithThrows(type, name: name, provider: provider)
    }
    
    public func resolveWithThrows<Object>(_ type: Object.Type, name: String) throws -> Object? {
        try self.container.resolveWithThrows(type, name: name)
    }
    
    public func register<Object>(_ type: Object.Type, name: String, provider: @escaping () -> Object) {
        self.container.register(type, name: name, provider: provider)
    }
    
    public func resolve<Object>(_ type: Object.Type, name: String) -> Object? {
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
    typealias ThrowsProvier = () throws -> Any
    typealias Provier = () -> Any
    private var verifyContainer: [String: Verify] = [:]
    private var providerContainer: [String: Provier] = [:]
    private var throwsProviderContainer: [String: ThrowsProvier] = [:]
    
    func registerWithThrows<Object>(_ type: Object.Type, name: String, provider: @escaping () throws -> Object) {
        self.throwsProviderContainer[name] = provider
    }
    
    func resolveWithThrows<Object>(_ type: Object.Type, name: String) throws -> Object? {
        let provider = throwsProviderContainer[name]
        let value = try provider?()
        return value as? Object
    }
    
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
