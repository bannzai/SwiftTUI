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
    public func accept<V: ViewContentVisitor>(visitor: V) -> V.VisitResult {
        return accept(visitor: visitor, with: .default)
    }
    public func accept<V: ViewContentVisitor>(visitor: V, with listOption: ViewVisitorListOption) -> V.VisitResult {
        Mirror(reflecting: value).children.forEach { (element) in
            if let value = element.value as? ViewAcceptable {
                value.accept(visitor: visitor)
            }
            switch listOption {
            case .vertical:
                visitor.add(string: "\n")
            case .horizontal:
                break
            }
        }
    }
}
