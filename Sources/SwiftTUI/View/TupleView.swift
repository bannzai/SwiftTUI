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

extension TupleView: ContainerViewContentAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        return accept(visitor: visitor, with: .default)
    }
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

extension TupleView: ContainerViewSizeAcceptable {
    internal func accept(visitor: ViewSizeVisitor) -> ViewSizeVisitor.VisitResult {
        return accept(visitor: visitor, with: .default)
    }
    internal func accept(visitor: ViewSizeVisitor, with listOption: ViewVisitorListOption) -> ViewSizeVisitor.VisitResult {
        fatalError("// TODO:")
//        Mirror(reflecting: value).children.forEach { (element) in
//            if let value = element.value as? ViewSizeAcceptable {
//                value.accept(visitor: visitor)
//            }
//
//            // TODO: Implement
//        }
    }
}
