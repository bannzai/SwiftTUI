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

extension TupleView: ContainerPrimitive {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraph(view: self)
        visitor.current?.addChild(graph)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        
        Mirror(reflecting: value).children.forEach { (element) in
            guard let value = element.value as? ContainerPrimitive else {
                return
            }
            _ = value.accept(visitor: visitor)
        }
        return graph
    }
}

extension TupleView: _ViewSizeAcceptable {
    internal func accept(visitor: ViewSizeVisitor, with argument: ViewSizeVisitor.Argument) -> ViewSizeVisitor.VisitResult {
        switch argument.listOption {
        case .vertical:
            let children = Mirror(reflecting: value).children
            var allocableHeight: PhysicalDistance = argument.proposedSize.height / (children.count - 1) * argument.space
            var maxElementWidth = argument.proposedSize.width
            children.enumerated().forEach { (offset, element) in
                guard let value = element.value as? _ViewSizeAcceptable else {
                    return
                }
                
                let provisionalElementHeight: PhysicalDistance = allocableHeight / (children.count - offset)
                let proposedSizedArgument = argument.change(proposedSize: Size(width: argument.proposedSize.width, height: max(provisionalElementHeight, 0)))
                let size = value.accept(visitor: visitor, with: proposedSizedArgument)
                maxElementWidth = max(maxElementWidth, size.width)
                allocableHeight -= size.height
            }
            
            switch allocableHeight {
            case let allocableHeight where allocableHeight < 0:
                _baseProperty.rect.size.height = argument.proposedSize.height + abs(allocableHeight)
            case let allocableHeight where allocableHeight > 0:
                _baseProperty.rect.size.height = argument.proposedSize.height - allocableHeight
            case _:
                _baseProperty.rect.size.height = argument.proposedSize.height
            }
            _baseProperty.rect.size.width = maxElementWidth
            return _baseProperty.rect.size
        case .horizontal:
            fatalError("TODO: Implement")
        }
    }
}
