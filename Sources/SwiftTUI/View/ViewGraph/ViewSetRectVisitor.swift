//
//  ViewSetRectVisitor.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

internal protocol ViewSetRectVisitorAcceptable {
    func accept(visitor: ViewSetRectVisitor) -> ViewSetRectVisitor.VisitResult
}

internal final class ViewSetRectVisitor: Visitor {
    internal typealias VisitResult = Void
    internal init() { }
    
    internal var currentContainerGraph: ViewGraph?

    internal func visit<T: View>(_ content: T) -> VisitResult {
        debugLogger.log()
        switch content {
        case let acceptable as ViewSetRectVisitorAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
