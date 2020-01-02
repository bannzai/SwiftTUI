//
//  Primitive.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

internal protocol Primitive {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

extension Primitive {
    func _accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraph(view: self)
        graph.parent = visitor.current
        graph.parent?.children.append(graph)
        return graph
    }
}

internal protocol ContainerPrimitive: Primitive {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

extension ContainerPrimitive {
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
