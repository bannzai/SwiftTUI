//
//  ViewGraph.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

internal final class ViewGraph {
    internal typealias View = Primitive

    internal weak var parent: ViewGraph?
    internal var children: [ViewGraph] = []
    
    internal weak var beforeRelation: ViewGraph?
    internal var afterRelation: ViewGraph?
    
    internal var rect: Rect = Rect(origin: .zero, size: .zero)
    
    internal var view: View
    internal init(view: View) {
        self.view = view
    }
    
    func addChild(_ node: ViewGraph) {
        children.append(node)
        node.parent = self
    }
    
    func addRelation(_ node: ViewGraph) {
        afterRelation = node
        node.beforeRelation = self
    }
}

internal final class ViewGraphSetVisitor {
    internal var current: ViewGraph? = nil
    
    internal func visit<T: View>(view: T) -> ViewGraph {
        switch view {
        case let tuple as ContainerViewGraphSetAcceptable:
            return tuple.accept(visitor: self)
        case let modifier as ViewGraphSetAttributeAcceptable:
            return modifier.accept(visitor: self)
        case let view as ViewGraphSetAcceptable:
            return view.accept(visitor: self)
        case _:
            return visit(view: view.body)
        }
    }
}
