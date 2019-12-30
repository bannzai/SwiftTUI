//
//  TupleView.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

/// A View created from a swift tuple of View values.
public struct TupleView<T> {
    public var _baseProperty: _ViewBaseProperties? = _ViewBaseProperties()
    
    public var value: T

    @inlinable public init(_ value: T) {
        self.value = value
    }
}

extension TupleView: View {
    public typealias Body = Never
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
    internal func accept(visitor: ViewSizeVisitor, with argument: ViewSizeVisitor.Argument) -> ViewSizeVisitor.VisitResult {
        var width: PhysicalDistance = 0
        var height: PhysicalDistance = 0
        Mirror(reflecting: value).children.forEach { (element) in
            guard let value = element.value as? ViewSizeAcceptable else {
                return
            }
            
            let size = value.accept(visitor: visitor)
            switch argument.listOption {
            case .vertical:
                width = max(width, size.width)
                height += size.height
                height += argument.space
            case .horizontal:
                height = max(height, size.height)
                width += size.width
                width += argument.space
            }
        }
        width = min(width, argument.parentViewProposedRect.size.width)
        height = min(height, argument.parentViewProposedRect.size.height)
        let size = Size(width: width, height: height)
        _baseProperty?.rect.size = size
        return size
    }
}
