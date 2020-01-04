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

extension VStack: ViewContentAcceptable {
    internal func accept<V: ViewContentVisitor>(visitor: V) -> V.VisitResult {
        let option = _VStackLayout._viewListOptions
        let keepAlignment = visitor.containerAlignment
        visitor.containerAlignment.horizontal = tree.root.alignment
        visitor.visit(tree.content, with: option)
        visitor.containerAlignment = keepAlignment
    }
}

extension VStack: _ViewSizeAcceptable {
    internal func accept<V: _ViewSizeVisitor>(visitor: V, with argument: _ViewSizeVisitor.Argument) -> V.VisitResult {
        let keepAlignment = visitor.containerAlignment
        defer {
            visitor.containerAlignment = keepAlignment
        }
        var argument = argument
        argument.listOption = ViewVisitorListOption.vertical
        argument.space = tree.root.spacing ?? ViewVisitorListOption.vertical.defaultSpace
        visitor.containerAlignment.horizontal = tree.root.alignment
        return visitor.visit(tree.content, with: argument)
    }
}

extension VStack: ViewGraphSetAcceptable {
    public func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        visitor.visit(view: tree)
//        let keepAlignment = visitor.containerAlignment
//        defer {
//            visitor.containerAlignment = keepAlignment
//        }
//        var argument = argument
//        argument.listOption = ViewVisitorListOption.vertical
//        argument.space = tree.root.spacing ?? ViewVisitorListOption.vertical.defaultSpace
//        visitor.containerAlignment.horizontal = tree.root.alignment
//        return visitor.visit(tree.content, with: argument)
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

extension _VStackLayout: VariadicView.Root {
    public static var _viewListOptions: ViewVisitorListOption { .vertical }
}
