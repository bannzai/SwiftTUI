//
//  HStack.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation

struct HStackVisitor<InnerVisitor: Visitor>: Visitor {
    let innerVisitor: InnerVisitor
    typealias VisitResult = [InnerVisitor.VisitResult]

    func visit<T>(_ content: T) -> VisitResult {
        guard let acceptable = content as? Acceptable else {
            fatalError("Unexpected visited value of \(content)")
        }
        return acceptable.accept(visitor: self)
    }
}

@frozen public struct HStack<Content> : View where Content : View {
    @usableFromInline
    internal var layout: _HStackLayout
    @usableFromInline
    internal var content: Content
    @inlinable public init(alignment: VerticalAlignment = .center, spacing: PhysicalDistance? = nil, @ViewBuilder content: () -> Content) {
        self.layout = _HStackLayout(alignment: alignment, spacing: spacing)
        self.content = content()
    }
    public typealias Body = Swift.Never
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
