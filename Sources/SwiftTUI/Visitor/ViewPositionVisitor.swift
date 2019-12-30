//
//  ViewPositionVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/31.
//

import Foundation

internal protocol ViewPositionAcceptable {
    func accept(visitor: ViewPositionVisitor) -> ViewPositionVisitor.VisitResult
}

internal protocol ContainerViewPositionAcceptable {
    func accept(visitor: ViewPositionVisitor, with argument: ViewPositionVisitor.Argument) -> ViewPositionVisitor.VisitResult
}

internal final class ViewPositionVisitor: Visitor {
    internal typealias VisitResult = Size
    internal init() { }
    
    internal var containerAlignment: Alignment = .default
    internal func visit<T: View>(_ content: T) -> VisitResult {
        fatalError("// TODO:")
    }
    internal func visit<T: View>(_ content: T, with argument: Argument) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let acceptable as ContainerViewPositionAcceptable:
            return acceptable.accept(visitor: self, with: argument)
        case let acceptable as ViewPositionAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body, with: argument)
        }
    }
}

extension ViewPositionVisitor {
    internal struct Argument {
        internal var listOption: ViewVisitorListOption
        internal var space: PhysicalDistance
    }
}
