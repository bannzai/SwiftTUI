//
//  HStack.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation

@frozen public struct HStack<Content> : View where Content : View {
    @usableFromInline internal var tree: VariadicView.Tree<_HStackLayout, Content>
    @inlinable public init(alignment: VerticalAlignment = .center, spacing: PhysicalDistance? = nil, @ViewBuilder content: () -> Content) {
        self.tree = VariadicView.Tree(
            root: _HStackLayout(alignment: alignment, spacing: spacing),
            content: content()
        )
    }
    public typealias Body = Swift.Never
}

extension HStack: ViewContentAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        visitor.visit(tree)
    }
}
extension HStack: _ViewSizeAcceptable {
    internal func accept<V: ViewSizeVisitor>(visitor: V, with argument: ViewSizeVisitor.Argument) -> V.VisitResult {
        let keepAlignment = visitor.containerAlignment
        defer {
            visitor.containerAlignment = keepAlignment
        }
        var argument = argument
        argument.listOption = ViewVisitorListOption.horizontal
        argument.space = tree.root.spacing ?? ViewVisitorListOption.horizontal.defaultSpace
        visitor.containerAlignment.vertical = tree.root.alignment
        return visitor.visit(tree.content, with: argument)
    }
}

extension HStack: ViewGraphSetAcceptable {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        visitor.visit(view: tree)
    }
}

@frozen public struct _HStackLayout {
  public var alignment: VerticalAlignment
  public var spacing: PhysicalDistance?
  @inlinable public init(alignment: VerticalAlignment = .center, spacing: PhysicalDistance? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }
//  public typealias AnimatableData = EmptyAnimatableData
  public typealias Body = Swift.Never
}

extension _HStackLayout: VariadicView.Root {
    public static var _viewListOptions: ViewVisitorListOption { .horizontal }
}
