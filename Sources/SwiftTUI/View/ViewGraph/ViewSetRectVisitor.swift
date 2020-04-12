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

internal protocol ViewSetRectVisitorSkip { }

internal final class ViewSetRectVisitor: Visitor {
    internal typealias VisitResult = Void
    internal init() { }
    
    internal var current: ViewGraph?
    internal var currentContainerGraph: ViewGraph?

    internal func visit<T: View>(_ content: T) -> VisitResult {
        debugLogger.debug(userInfo: "begin set rect visitor: \(type(of: content))")
        defer {
            debugLogger.debug(userInfo: "end set rect visitor: \(type(of: content))")
        }
        switch content {
        case let acceptable as ViewSetRectVisitorAcceptable:
            return acceptable.accept(visitor: self)
        case is ViewSetRectVisitorSkip:
            return
        case _:
            return visit(content.body)
        }
    }
}
