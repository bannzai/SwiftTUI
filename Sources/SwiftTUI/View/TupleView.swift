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
    public var _baseProperty: _ViewBaseProperties? {
        _ViewBaseProperties()
    }
}

extension TupleView: ViewAcceptableWithListOption {
    public func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
        return accept(visitor: visitor, with: .default)
    }
    public func accept<V: AnyViewVisitor>(visitor: V, with listOption: ViewVisitorListOption) -> V.VisitResult {
        Mirror(reflecting: value).children.reduce(into: V.VisitResult.empty()) { (result, element) in
            if let value = element.value as? Acceptable {
                result.collect(with: value.accept(visitor: visitor))
            }
            switch listOption {
            case .vertical:
                result.collect(with: "\n")
            case .horizontal:
                break
            }
        }
    }
}
