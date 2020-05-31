//
//  ViewSetDimensionsVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/05/31.
//

import Foundation

internal protocol ViewSetDimensionsVisitorAcceptable {
    func accept(visitor: ViewSetDimensionsVisitor)
}

internal final class ViewSetDimensionsVisitor: Visitor {
    internal init() { }
    
    internal var current: ViewGraph!
    internal var currentContainerGraph: ViewGraph?
    internal func visit<T: View>(_ content: T) {
        debugLogger.debug(userInfo: "begin set content size visitor: \(type(of: content))")
        defer {
            debugLogger.debug(userInfo: "end set content size visitor: \(type(of: content))")
        }
        switch content {
        case let acceptable as ViewSetDimensionsVisitorAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
