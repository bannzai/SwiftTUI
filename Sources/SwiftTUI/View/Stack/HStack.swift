//
//  HStack.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation

class HStackVisitor: AnyListViewVisitor {
    override internal func visit<T: View>(_ content: T) -> VisitResult {
        guard let acceptable = content as? Acceptable else {
            return visit(content)
        }
        return acceptable.accept(visitor: self)
    }
}

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

extension HStack: Acceptable {
    public func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
        visitor.visit(tree)
    }
    public func accept<V: AnyListViewVisitor>(visitor: V) -> AnyListViewVisitor.VisitResult {
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

extension _HStackLayout: VariadicView.Root { }
