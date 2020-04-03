//
//  Group.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

/// An affordance for grouping view content.
@frozen public struct Group<Content: View>: View {
    @usableFromInline internal var content: Content
    
    public typealias Body = Never
    
    @inlinable public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

extension Group: ViewContentAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        visitor.visit(content)
    }
}
