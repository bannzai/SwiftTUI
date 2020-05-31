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
            let keepCurrent = current
            defer { current = keepCurrent }
            current = graph
            return acceptable.accept(visitor: self)
        }
        if let graph = content as? ViewGraph, graph.isUserDefinedView {
            assert(graph.children.count == 1, "it should want one child")
            let child = graph.children[0]
            graph.rect.origin = child.rect.origin
            return
        }
        return visit(content.body)
    }
}
