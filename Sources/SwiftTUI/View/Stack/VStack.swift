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
