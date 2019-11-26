//
//  HStack.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation

class HStackVisitor: AnyListViewVisitor {
    override internal func visit<T: View>(_ content: T) -> VisitResult {
        content.accept(visitor: self)
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

extension HStack {
    public func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
        tree
            .accept(visitor: HStackVisitor())
            .reduce(into: V.VisitResult.empty()) { result, element in
                result.collect(with: element)
        }
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
