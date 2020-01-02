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
    internal var view: View
    internal var rect: Rect = Rect(origin: .zero, size: .zero)
    
    internal init(view: View) {
        self.view = view
    }
}

extension TupleView: ContainerPrimitive {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraph(view: self)
        graph.parent = visitor.current
        graph.parent?.children.append(graph)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        
        Mirror(reflecting: value).children.forEach { (element) in
            guard let value = element.value as? ContainerPrimitive else {
                return
            }
            _ = value.accept(visitor: visitor)
        }
        return graph
    }
}

internal final class ViewGraphSetVisitor {
    internal var current: ViewGraph? = nil
    internal func visit<T: View>(view: T) -> ViewGraph {
        switch view {
        case let tuple as ContainerPrimitive:
            return tuple.accept(visitor: self)
        case let view as Primitive:
            return view.accept(visitor: self)
        case _:
            return visit(view: view.body)
        }
    }
}
