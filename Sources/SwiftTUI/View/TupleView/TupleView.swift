//
//  TupleView.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

/// A View created from a swift tuple of View values.
@frozen public struct TupleView<T> {
    public var value: T

    @inlinable public init(_ value: T) {
        self.value = value
    }
}

extension TupleView: View {
    public typealias Body = Never
}

extension TupleView: Primitive { }
extension TupleView: Rendable { }
extension TupleView: ContainerViewGraphSetAcceptable {
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        _accept(visitor: visitor, value: value)
    }
}
internal protocol _TupleView {
    func each(visitor: ViewGraphSetVisitor, closure: (ViewGraph) -> Void)
}
extension TupleView: _TupleView {
    func each(visitor: ViewGraphSetVisitor, closure: (ViewGraph) -> Void) {
        closure(_accept(visitor: visitor, value: value))
    }
}
