//
//  Group.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

/// An affordance for grouping view content.
public struct Group<Content: View>: View {
    public let content: Content
    
    public typealias Body = Never
    
    @inlinable public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

extension Group: Acceptable {
    public func _typeOf() -> _ExpectedAcceptableType {
        .group
    }
    public func accept<V>(visitor: V) -> V.VisitResult where V: Visitor {
        content.accept(visitor: visitor)
    }
}
