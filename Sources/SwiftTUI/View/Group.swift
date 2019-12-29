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
    
    public var _baseProperty: _ViewBaseProperties? {
        _ViewBaseProperties()
    }
}

extension Group: ViewContentAcceptable {
    internal func accept<V: ViewContentVisitor>(visitor: V) -> V.VisitResult {
        visitor.visit(content)
    }
}
