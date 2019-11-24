//
//  VariadicView.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/15.
//

import Foundation

public enum VariadicView {
    public typealias Root = _VariadicView_Root
    @frozen public struct Tree<Root, Content> where Root : _VariadicView_Root, Content: Acceptable {
        public var root: Root
        public var content: Content
        @inlinable internal init(root: Root, content: Content) {
            self.root = root
            self.content = content
        }
        @inlinable public init(_ root: Root, @ViewBuilder content: () -> Content) {
            self.root = root
            self.content = content()
        }
    }
}

extension VariadicView.Tree: Acceptable {
    public func _typeOf() -> _AcceptableType {
        .variadicViewTree
    }
    public func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
        content.accept(visitor: visitor)
    }
    public func accept<V>(visitor: V) -> AnyListViewVisitor.VisitResult where V : AnyListViewVisitor {
        content.accept(visitor: visitor)
    }
}

public protocol _VariadicView_Root {
    // TODO:
//    static var _viewListOptions: Swift.Int { get }
}
extension _VariadicView_Root {
    // TODO:
//    public static var _viewListOptions: Swift.Int { 0 }
}
