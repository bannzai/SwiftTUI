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
        graph.contentSize = graph.children.reduce(into: Size.zero) { (result, element) in
            result.width += element.contentSize.width
            result.height += element.contentSize.height
        }
    }
}

extension TupleView: ViewSetSizeVisitorAcceptable {
    private func verticalContextSize(viewGraph: ViewGraph) -> Size {
        var allocableHeight: PhysicalDistance = viewGraph.proposedSize.height - (viewGraph.children.count - 1) * viewGraph.spacing
        var maxElementWidth: PhysicalDistance = 0
        viewGraph.children.enumerated().forEach { (offset, element) in
            let provisionalElementHeight: PhysicalDistance = allocableHeight / (viewGraph.children.count - offset)
            let elementProposedSize = Size(width: viewGraph.proposedSize.width, height: max(provisionalElementHeight, 0))
            element.proposedSize = elementProposedSize
            
            maxElementWidth = max(maxElementWidth, element.rect.size.width + element.rect.origin.x)
            allocableHeight -= element.rect.size.height
        }
        
        maxElementWidth = min(maxElementWidth, viewGraph.proposedSize.width)
        
        switch allocableHeight {
        case let allocableHeight where allocableHeight < 0:
            return Size(width: maxElementWidth, height: viewGraph.proposedSize.height + abs(allocableHeight))
        case let allocableHeight where allocableHeight > 0:
            return Size(width: maxElementWidth, height: viewGraph.proposedSize.height - allocableHeight)
        case _:
            return Size(width: maxElementWidth, height: viewGraph.proposedSize.height)
        }
    }
    
    func accept(visitor: ViewSetSizeVisitor) {
        let viewGraph = visitor.current!
        switch viewGraph.listType {
        case .vertical:
            viewGraph.rect.size = verticalContextSize(viewGraph: viewGraph)
        case .horizontal:
            fatalError()
        }
    }
}
