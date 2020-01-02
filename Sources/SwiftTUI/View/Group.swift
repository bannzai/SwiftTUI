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

extension Group: ViewContentAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        visitor.visit(content)
    }
}
extension Group: _ViewSizeAcceptable {
    internal func accept(visitor: ViewSizeVisitor, with argument: ViewSizeVisitor.Argument) -> ViewSizeVisitor.VisitResult {
        visitor.visit(content, with: argument)
    }
}
