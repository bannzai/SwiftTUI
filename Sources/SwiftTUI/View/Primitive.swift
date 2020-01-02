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

internal protocol ViewGraphSetAttributeAcceptable {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

internal protocol ContainerViewGraphSetAcceptable {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

extension ViewGraphSetAcceptable where Self: Primitive {
    func _accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraph(view: self)
        visitor.current?.addChild(graph)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        return graph
    }
}

extension ViewGraphSetAttributeAcceptable where Self: Primitive {
    func _accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraph(view: self)
        visitor.current?.addRelation(graph)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        return graph
    }
}

extension ContainerViewGraphSetAcceptable where Self: Primitive {
    func _accept<T>(visitor: ViewGraphSetVisitor, value: T) -> ViewGraph {
        let graph = ViewGraph(view: self)
        visitor.current?.addChild(graph)
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
