//
//  TupleView.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

/// A View created from a swift tuple of View values.
public struct TupleView<T> {
    public var value: T

    @inlinable public init(_ value: T) {
        self.value = value
    }
}

extension TupleView: View {
    public typealias Body = Never
}

extension TupleView: Acceptable {
    public func _typeOf() -> _ExpectedAcceptableType {
        .tuple
    }
    public func accept<V>(visitor: V) -> V.VisitResult where V: Visitor {
        Mirror(reflecting: value).children.reduce(into: V.VisitResult.empty()) { (result, element) in
            if let value = element.value as? Acceptable {
                result.collect(with: value.accept(visitor: visitor))
            }
        }
    }
}
