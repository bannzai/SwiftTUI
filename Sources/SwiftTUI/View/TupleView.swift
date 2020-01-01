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
        var width: PhysicalDistance = 0
        var height: PhysicalDistance = 0
        let children = Mirror(reflecting: value).children
        
        _baseProperty.rect.size.width = argument.proposedSize.width
        _baseProperty.rect.size.height = argument.proposedSize.height
        
        switch argument.listOption {
        case .vertical:
            var totalElementHeight: PhysicalDistance = 0
            var maxElementWidth = _baseProperty.rect.size.width
            children.enumerated().forEach { (offset, element) in
                guard let value = element.value as? ViewSizeAcceptable else {
                    return
                }
                
                let proposedSizedArgument = argument.change(proposedSize: Size(width: argument.proposedSize.width, height: _baseProperty.rect.size.height - max(totalElementHeight, 0)))
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
