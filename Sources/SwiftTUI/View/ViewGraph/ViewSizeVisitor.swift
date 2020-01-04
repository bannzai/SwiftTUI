//
//  ViewSizeVisitor.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

internal protocol ViewSizeAcceptable {
    func accept(visitor: ViewSizeVisitor, with argument: ViewSizeVisitor.Argument) -> ViewSizeVisitor.VisitResult
}

internal final class ViewSizeVisitor: Visitor {
    internal typealias VisitResult = Size
    internal init() { }
    
    internal var containerAlignment: Alignment = .default
    internal func visit<T: View>(_ content: T, with argument: Argument) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let acceptable as ViewSizeAcceptable:
            return acceptable.accept(visitor: self, with: argument)
        case _:
            return visit(content.body, with: argument)
        }
    }
}

extension ViewSizeVisitor {
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
