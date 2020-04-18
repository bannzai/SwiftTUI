//
//  VStack.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/13.
//

import Foundation

@frozen public struct VStack<Content> : View where Content : View {
    @usableFromInline internal var tree: VariadicView.Tree<_VStackLayout, Content>
    @inlinable public init(alignment: HorizontalAlignment = .center, spacing: PhysicalDistance? = nil, @ViewBuilder content: () -> Content) {
        self.tree = VariadicView.Tree(
            root: _VStackLayout(alignment: alignment, spacing: spacing),
            content: content()
        )
    }
    public typealias Body = Swift.Never
}

extension VStack: ContainerViewType { }
extension VStack: Rendable { }
extension VStack: ViewGraphSetAcceptable {
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraphImpl(view: self)
        graph.listType = .vertical
        graph.alignment.horizontal = tree.root.alignment
        graph.spacing = tree.root.spacing ?? graph.listType.defaultSpace
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        graph.addChild(visitor.visit(tree.content))
        return graph
    }
}

@frozen public struct _VStackLayout {
    @usableFromInline internal var alignment: HorizontalAlignment
    @usableFromInline internal var spacing: PhysicalDistance?
    @inlinable internal init(alignment: HorizontalAlignment = .default, spacing: PhysicalDistance? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }
    //  public typealias AnimatableData = EmptyAnimatableData
    public typealias Body = Swift.Never
}

extension _VStackLayout: VariadicView.Root { }

extension VStack: HasContainerContentSize {
    func containerContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size {
        var allocableHeight: PhysicalDistance = viewGraph.proposedSize.height - (viewGraph.rendableChildren.count - 1) * viewGraph.spacing
        var maxElementWidth: PhysicalDistance = 0
        viewGraph.rendableChildren.enumerated().forEach { (offset, element) in
            let provisionalElementHeight: PhysicalDistance = allocableHeight / (viewGraph.rendableChildren.count - offset)
            let elementProposedSize = Size(width: viewGraph.proposedSize.width, height: max(provisionalElementHeight, 0))
            element.proposedSize = elementProposedSize
            element.accept(visitor: visitor)
            
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
}
