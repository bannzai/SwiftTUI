//
//  AnyView.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation

/// A type-erased `View`.
///
/// An `AnyView` allows changing the type of view used in a given view
/// hierarchy. Whenever the type of view used with an `AnyView`
/// changes, the old hierarchy is destroyed and a new hierarchy is
/// created for the new type.
public struct AnyView: View {
    fileprivate class AnyViewStorage<T: View>: AnyViewStorageBase {
        let view: T
        init(_ view: T) {
            self.view = view
        }
        public override func accept<V>(visitor: V) -> V.VisitResult where V: Visitor {
            view.accept(visitor: visitor)
        }
    }

    let storage: AnyViewStorageBase
    
    /// Create an instance that typeerases `view`.
    public init<V>(_ view: V) where V: View {
        self.storage = AnyViewStorage(view)
    }

    public typealias Body = Never
}

extension AnyView: Acceptable {
    public func _typeOf() -> _ExpectedAcceptableType { .any }
    public func accept<V>(visitor: V) -> V.VisitResult where V: Visitor {
        storage.accept(visitor: visitor)
    }
}
