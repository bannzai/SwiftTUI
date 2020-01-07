//
//  ViewPositionVisitor.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/01/08.
//

import Foundation

internal protocol ViewPositionAcceptable {
    func accept(visitor: ViewPositionVisitor) -> ViewPositionVisitor.VisitResult
}

internal final class ViewPositionVisitor: Visitor {
    internal typealias VisitResult = Point
    internal init() { }
    
    internal func visit<T: View>(_ content: T) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let acceptable as ViewPositionAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
