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
        if let graph = content as? ViewGraph, let acceptable = graph.anyView as? ViewSetPositionVisitorAcceptable {
            return acceptable.accept(visitor: self)
        }
        if let graph = content as? ViewGraph {
            return graph.children.forEach(visit)
        }
        return visit(content.body)
    }
}
