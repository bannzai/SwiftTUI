//
//  Primitive.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

public protocol ViewGraphSetAcceptable {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

internal protocol ViewGraphSetAttributeAcceptable {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

internal protocol ContainerViewGraphSetAcceptable  {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph
}

extension ViewGraphSetAcceptable where Self: Primitive, Self: View {
    func _accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraphImpl(view: self)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        return graph
    }
}

extension ContainerViewGraphSetAcceptable where Self: View, Self: Primitive {
    func _accept<T>(visitor: ViewGraphSetVisitor, value: T) -> ViewGraph {
        let graph = ViewGraphImpl(view: self)
        visitor.current?.inheritProperties(to: graph)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph

        Mirror(reflecting: value).children.enumerated().forEach { (offset, element) in
            switch element.value {
            case let tuple as ContainerViewGraphSetAcceptable:
                graph.addChild(tuple.accept(visitor: visitor))
            case let modifier as ViewGraphSetAttributeAcceptable:
                graph.addChild(modifier.accept(visitor: visitor))
            case let view as ViewGraphSetAcceptable:
                graph.addChild(view.accept(visitor: visitor))
            case let _view as _View:
                graph.addChild(visitor.visit(view: _view._wrappedViewForBuildGraph))
            case _:
                fatalError("Unexpected type value \(type(of: element.value))")
            }
        }
        return graph
    }
}

internal protocol Primitive {
    
}
