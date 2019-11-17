//
//  VStack.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/13.
//

import Foundation

struct VStackVisitor<InnerVisitor: Visitor>: Visitor {
    let innerVisitor: InnerVisitor
    typealias VisitResult = [InnerVisitor.VisitResult]
    
    func visit<T>(_ content: T) -> VisitResult {
        guard let acceptable = content as? Acceptable else {
            fatalError("Unexpected visited value of \(content)")
        }
        return acceptable.accept(visitor: self)
    }
}

@frozen public struct VStack<Content> : View where Content : View {
    @usableFromInline internal var tree: VariadicView.Tree<_VStackLayout, Content>
    @inlinable public init(alignment: VerticalAlignment = .center, spacing: PhysicalDistance? = nil, @ViewBuilder content: () -> Content) {
        self.tree = VariadicView.Tree(
            root: _VStackLayout(alignment: alignment, spacing: spacing),
            content: content()
        )
    }
    public typealias Body = Swift.Never
}

extension VStack: Acceptable {
    public func accept<V>(visitor: V) -> V.VisitResult where V: Visitor {
        tree
            .accept(visitor: VStackVisitor(innerVisitor: visitor))
            .reduce(into: V.VisitResult.empty()) { result, element in
                result.collect(with: element)
        }
    }
}

@frozen public struct _VStackLayout {
    public var alignment: VerticalAlignment
    public var spacing: PhysicalDistance?
    @inlinable public init(alignment: VerticalAlignment = .center, spacing: PhysicalDistance? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }
    //  public typealias AnimatableData = EmptyAnimatableData
    public typealias Body = Swift.Never
}

extension _VStackLayout: VariadicView.Root { }