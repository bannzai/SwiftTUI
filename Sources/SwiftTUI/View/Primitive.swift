//
//  Primitive.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

internal protocol ViewGraphSetAcceptable {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

extension ViewGraphSetAcceptable where Self: Primitive {
    func _accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraph(view: self)
        graph.parent = visitor.current
        graph.parent?.children.append(graph)
        return graph
    }
}

internal protocol ContainerViewGraphSetAcceptable {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

extension ContainerViewGraphSetAcceptable where Self: Primitive {
    func _accept<T>(visitor: ViewGraphSetVisitor, value: T) -> ViewGraph {
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

internal protocol Primitive {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

internal protocol ContainerPrimitive: ViewGraphSetAcceptable {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}
