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
        internal let view: T
        internal init(_ view: T) {
            self.view = view
        }
        
        internal override func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
            visitor.visit(view)
        }
        internal override func accept(visitor: _ViewSizeVisitor, with argument: _ViewSizeVisitor.Argument) -> _ViewSizeVisitor.VisitResult {
            visitor.visit(view, with: argument)
        }
    }

    let storage: AnyViewStorageBase
    
    /// Create an instance that typeerases `view`.
    public init<V>(_ view: V) where V: View {
        self.storage = AnyViewStorage(view)
    }

    public typealias Body = Never
}

extension AnyView: Primitive { }

extension AnyView: ViewContentAcceptable {
    internal func accept<V>(visitor: V) -> ViewContentVisitor.VisitResult where V : ViewContentVisitor {
        storage.accept(visitor: visitor)
    }
}
extension AnyView: _ViewSizeAcceptable {
    internal func accept<V: _ViewSizeVisitor>(visitor: V, with argument: _ViewSizeVisitor.Argument) -> V.VisitResult {
        storage.accept(visitor: visitor, with: argument)
    }
}
