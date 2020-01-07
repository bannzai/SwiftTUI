//
//  TupleView.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

/// A View created from a swift tuple of View values.
@frozen public struct TupleView<T> {
    internal var _baseProperty: _ViewBaseProperties = _ViewBaseProperties()
    
    public var value: T

    @inlinable public init(_ value: T) {
        self.value = value
    }
}

extension TupleView: View, Primitive {
    public typealias Body = Never
}

extension TupleView: ContainerViewContentAcceptable {
    internal func accept(visitor: ViewContentVisitor, with listOption: ViewVisitorListOption) -> ViewContentVisitor.VisitResult {
        Mirror(reflecting: value).children.forEach { (element) in
            if let value = element.value as? ViewContentAcceptable {
                value.accept(visitor: visitor)
            }
            switch listOption {
            case .vertical:
                visitor.driver.add(string: "\n")
            case .horizontal:
                break
            }
        }
    }
}

extension TupleView: ContainerViewGraphSetAcceptable {
    public func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        _accept(visitor: visitor, value: value)
    }
}
