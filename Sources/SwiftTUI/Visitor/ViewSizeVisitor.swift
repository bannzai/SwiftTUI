//
//  SizeVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/29.
//

import Foundation

internal protocol ViewSizeAcceptable {
    func accept(visitor: ViewSizeVisitor) -> ViewSizeVisitor.VisitResult
}

internal protocol ContainerViewSizeAcceptable {
    func accept(visitor: ViewSizeVisitor, with argument: ViewSizeVisitor.Argument) -> ViewSizeVisitor.VisitResult
}

internal final class ViewSizeVisitor: Visitor {
    internal typealias VisitResult = Size
    internal init() { }
    
    internal var containerAlignment: Alignment = .default
    internal func visit<T: View>(_ content: T) -> VisitResult {
        fatalError("// TODO:")
    }
    internal func visit<T: View>(_ content: T, with argument: Argument) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let acceptable as ContainerViewSizeAcceptable:
            return acceptable.accept(visitor: self, with: argument)
        case let acceptable as ViewSizeAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body, with: argument)
        }
    }
}

extension ViewSizeVisitor {
    internal struct Argument {
        internal var listOption: ViewVisitorListOption
        internal var space: PhysicalDistance
    }
}
