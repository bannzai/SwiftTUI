//
//  _ViewSizeVisitor.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

internal protocol ViewRectSetAcceptable {
    func accept(visitor: ViewRectSetVisitor, with argument: ViewRectSetVisitor.Argument) -> ViewRectSetVisitor.VisitResult
}

internal final class ViewRectSetVisitor: Visitor {
    internal typealias VisitResult = Rect
    internal init() { }
    
    internal var containerAlignment: Alignment = .default
    internal func visit(content: ViewGraph, with argument: Argument) -> VisitResult {
        debugLogger.debug()
        return content.accept(visitor: self, with: argument)
    }
}

extension ViewRectSetVisitor {
    internal struct Argument {
        internal var listOption: ViewVisitorListOption
        internal var space: PhysicalDistance
        internal var proposedSize: Size
        
        func change(proposedSize: Size) -> Self {
            var argument = self
            argument.proposedSize = proposedSize
            return argument
        }
    }
}
