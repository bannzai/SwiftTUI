//
//  ViewAlignmentVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/31.
//

import Foundation

internal protocol ViewAlignmentAcceptable {
    func accept(visitor: ViewAlignmentVisitor) -> ViewAlignmentVisitor.VisitResult
}

internal protocol ContainerViewAlignmentAcceptable {
    func accept(visitor: ViewAlignmentVisitor, with argument: ViewAlignmentVisitor.Argument) -> ViewAlignmentVisitor.VisitResult
}

internal final class ViewAlignmentVisitor: Visitor {
    internal typealias VisitResult = Alignment
    internal init() { }
    
    internal var containerAlignment: Alignment = .default
    internal func visit<T: View>(_ content: T) -> VisitResult {
        fatalError("// TODO:")
    }
    internal func visit<T: View>(_ content: T, with argument: Argument) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let acceptable as ContainerViewAlignmentAcceptable:
            return acceptable.accept(visitor: self, with: argument)
        case let acceptable as ViewAlignmentAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body, with: argument)
        }
    }
}

extension ViewAlignmentVisitor {
    internal struct Argument {
        internal var space: Alignment
    }
}
