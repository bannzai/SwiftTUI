//
//  TupleView.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

/// A View created from a swift tuple of View values.
public struct TupleView<T> {
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

extension TupleView: ViewSizeAcceptable {
    internal func accept(visitor: ViewSizeVisitor, with argument: ViewSizeVisitor.Argument) -> ViewSizeVisitor.VisitResult {
        switch argument.listOption {
        case .vertical:
            var totalElementHeight: PhysicalDistance = 0
            var maxElementWidth = argument.proposedSize.width
            Mirror(reflecting: value).children.enumerated().forEach { (offset, element) in
                guard let value = element.value as? ViewSizeAcceptable else {
                    return
                }
                
                let proposedSizedArgument = argument.change(proposedSize: Size(width: argument.proposedSize.width, height: argument.proposedSize.height - max(totalElementHeight, 0)))
                let size = value.accept(visitor: visitor, with: proposedSizedArgument)
                maxElementWidth = max(maxElementWidth, size.width)
                totalElementHeight += size.height
            }
            
            _baseProperty.rect.size.width = maxElementWidth
            _baseProperty.rect.size.height = totalElementHeight
            return _baseProperty.rect.size
        case .horizontal:
            fatalError("TODO: Implement")
        }
    }
}
