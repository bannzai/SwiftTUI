//
//  ViewSetPositionVisitor.swift
//  Demo
//
//  Created by yudai-hirose on 2020/05/31.
//

import Foundation

internal protocol ViewSetPositionVisitorAcceptable {
    func accept(visitor: ViewSetPositionVisitor)
}

internal final class ViewSetPositionVisitor: Visitor {
    internal init() { }
    
    internal var current: ViewGraph!
    internal func visit<T: View>(_ content: T) {
        debugLogger.debug(userInfo: "begin set positon visitor: \(type(of: content))")
        defer {
            debugLogger.debug(userInfo: "end set positon visitor: \(type(of: content))")
        }
        switch content {
        case let acceptable as ViewSetPositionVisitorAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
