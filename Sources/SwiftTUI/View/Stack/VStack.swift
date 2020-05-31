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
        let child = visitor.visit(tree.content)
        graph.addChild(child)
        return graph
    }
}

extension VStack: ViewSetContentSizeVisitorAcceptable {
    func accept(visitor: ViewSetContentSizeVisitor) {
        let graph = visitor.current!
        graph.contentSize = graph.children.reduce(into: Size.zero) { (result, element) in
            result.width += element.contentSize.width
            result.width += element.contentSize.height
        }
    }
}
extension VStack: ViewSetPositionVisitorAcceptable {
    func accept(visitor: ViewSetPositionVisitor) {
        
    }
}
extension VStack: ViewSetSizeVisitorAcceptable {
    func accept(visitor: ViewSetSizeVisitor) {
        let graph = visitor.current!
        assert(graph.children.count == 1, "it should want one child")
        let child = graph.children[0]
        
        graph.rect.size = child.rect.size
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
extension VStack: HasContainerContentSize { }
