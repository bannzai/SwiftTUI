//
//  SizeVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/29.
//

import Foundation

internal protocol _ViewSizeAcceptable {
    func accept(visitor: _ViewSizeVisitor, with argument: _ViewSizeVisitor.Argument) -> _ViewSizeVisitor.VisitResult
}

internal final class _ViewSizeVisitor: Visitor {
    internal typealias VisitResult = Size
    internal init() { }
    
    internal var containerAlignment: Alignment = .default
    internal func visit<T: View>(_ content: T, with argument: Argument) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let acceptable as _ViewSizeAcceptable:
            return acceptable.accept(visitor: self, with: argument)
        case _:
            return visit(content.body, with: argument)
        }
    }
}

extension _ViewSizeVisitor {
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
