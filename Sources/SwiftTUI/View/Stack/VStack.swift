//
//  VStack.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/13.
//

import Foundation

class VStackVisitor: AnyListViewVisitor {
    override internal func visit<T: View>(_ content: T) -> VisitResult {
        guard let acceptable = content as? Acceptable else {
            return visit(content)
        }
        return acceptable.accept(visitor: self)
    }
}

@frozen public struct VStack<Content> : View where Content : View {
    @usableFromInline internal var tree: VariadicView.Tree<_VStackLayout, Content>
    @inlinable public init(alignment: HorizontalAlignment = .center, spacing: PhysicalDistance? = nil, @ViewBuilder content: () -> Content) {
        self.tree = VariadicView.Tree(
            root: _VStackLayout(alignment: alignment, spacing: spacing),
            content: content()
        )
    }
    public typealias Body = Swift.Never
    public var _baseProperty: _ViewBaseProperties? {
        _ViewBaseProperties()
    }
}

extension VStack: Acceptable {
    public func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
        visitor.visit(tree)
    }
    public func accept<V: AnyListViewVisitor>(visitor: V) -> AnyListViewVisitor.VisitResult {
        visitor.visit(tree)
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
