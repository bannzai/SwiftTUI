//
//  ViewSetSizeVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/05/31.
//

import Foundation

internal protocol ViewSetSizeVisitorAcceptable {
    func accept(visitor: ViewSetSizeVisitor)
}

internal final class ViewSetSizeVisitor: Visitor {
    internal init() { }
    
    internal var current: ViewGraph!
    internal func visit<T: View>(_ content: T) {
        debugLogger.debug(userInfo: "begin set size visitor: \(type(of: content))")
        defer {
            debugLogger.debug(userInfo: "end set size visitor: \(type(of: content))")
        }
        if let graph = content as? ViewGraph, let acceptable = graph.anyView as? ViewSetSizeVisitorAcceptable {
            let keepCurrent = current
            defer { current = keepCurrent }
            current = graph
            return acceptable.accept(visitor: self)
        }
        if let graph = content as? ViewGraph {
            return graph.children.forEach(visit)
        }
        return visit(content.body)
    }
}
