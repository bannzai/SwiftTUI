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
extension TupleView: ContainerViewType { }
extension TupleView: HasContainerContentSize { }
internal protocol _TupleView { }
extension TupleView: _TupleView { }

extension TupleView: ViewSetContentSizeVisitorAcceptable {
    func accept(visitor: ViewSetContentSizeVisitor) {
        let graph = visitor.current!
        graph.children.reduce(into: Size.zero) { (result, element) in
            graph.contentSize.width += element.contentSize.width
            graph.contentSize.height += element.contentSize.height
        }
    }
}
