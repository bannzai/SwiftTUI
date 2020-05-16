//
//  ViewSetContentSizeVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/05/16.
//

import Foundation

internal protocol ViewSetContentSizeVisitorAcceptable {
    func accept(visitor: ViewSetContentSizeVisitor)
}

internal final class ViewSetContentSizeVisitor: Visitor {
    internal init() { }
    
    internal var current: ViewGraph!
    internal func visit<T: View>(_ content: T) {
        debugLogger.debug(userInfo: "begin set content size visitor: \(type(of: content))")
        defer {
            debugLogger.debug(userInfo: "end set content size visitor: \(type(of: content))")
        }
        switch content {
        case let acceptable as ViewSetContentSizeVisitorAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
