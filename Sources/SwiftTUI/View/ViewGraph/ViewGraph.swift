//
//  ViewGraph.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

public class ViewGraph {
    internal lazy var identifier: ObjectIdentifier = .init(self)
    
    internal weak var parent: ViewGraph?
    internal var children: Set<ViewGraph> = []
    
    internal weak var beforeRelation: ViewGraph?
    internal var afterRelation: ViewGraph?
    
    internal var rect: Rect = Rect(origin: .zero, size: .zero)

    internal func addChild(_ node: ViewGraph) {
        children.insert(node)
        node.parent = self
    }
    
    internal func addRelation(_ node: ViewGraph) {
        afterRelation = node
        node.beforeRelation = self
    }
}

public final class _ViewGraph<View: SwiftTUI.View>: ViewGraph {
    internal let view: View
    internal init(view: View) {
        self.view = view
    }
}

extension ViewGraph: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: ViewGraph, rhs: ViewGraph) -> Swift.Bool {
        lhs.identifier == rhs.identifier
    }
}

public final class ViewGraphSetVisitor {
    internal var current: ViewGraph? = nil
    internal init() { }
    
    internal func visit<T: View>(view: T) -> ViewGraph {
        switch view {
        case let tuple as ContainerViewGraphSetAcceptable:
            return tuple.accept(visitor: self)
        case let modifier as ViewGraphSetAttributeAcceptable:
            return modifier.accept(visitor: self)
        case let view as ViewGraphSetAcceptable:
            return view.accept(visitor: self)
        }
    }
}

extension ViewGraph: ViewRectSetAcceptable {
    func accept(visitor: ViewRectSetVisitor, with argument: ViewRectSetVisitor.Argument) -> ViewRectSetVisitor.VisitResult {
        
    }
}
