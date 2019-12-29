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
    public var _baseProperty: _ViewBaseProperties? {
        _ViewBaseProperties()
    }
}

extension HStack: ViewContentAcceptable {
    internal func accept<V: ViewContentVisitor>(visitor: V) -> V.VisitResult {
        visitor.visit(tree)
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
