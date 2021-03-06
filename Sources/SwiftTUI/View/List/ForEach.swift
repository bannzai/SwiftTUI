//
//  ForEach.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/14.
//

import Foundation

public struct ForEach<Data, ID, Content> where Data: Swift.RandomAccessCollection, ID: Swift.Hashable, Content: View {
    public var data: Data
    public var content: (Data.Element) -> Content
}
extension ForEach: ContainerViewType { }
extension ForEach: Primitive { }
extension ForEach: Rendable { }
extension ForEach: View {
    public typealias Body = Swift.Never
}
extension ForEach where ID == Data.Element.ID, Content: View, Data.Element: Swift.Identifiable {
    public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
}
extension ForEach where Content: View {
    public init(_ data: Data, id: Swift.KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
}
extension ForEach where Data == Swift.Range<Swift.Int>, ID == Swift.Int, Content: View {
    public init(_ data: Swift.Range<Swift.Int>, @ViewBuilder content: @escaping (Swift.Int) -> Content) {
        self.data = data
        self.content = content
    }
}

extension ForEach: ViewGraphSetAcceptable {
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        if visitor.current?.anyView is ContainerViewType {
            each(visitor: visitor) { (child) in
                visitor.current?.addChild(child)
            }
            return ViewGraphNone()
        }

        let graph = ViewGraphImpl(view: self)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        
        data.forEach { d in
            let child = visitor.visit(content(d))
            if child.anyView is _TupleView {
                child.children.forEach(graph.addChild)
                return
            }
            graph.addChild(child)
        }
        return graph
    }
}

internal protocol _ForEach {
    func each(visitor: ViewGraphSetVisitor, closure: (ViewGraph) -> Void)
}
extension ForEach: _ForEach {
    func each(visitor: ViewGraphSetVisitor, closure: (ViewGraph) -> Void) {
        data.forEach { d in
            let child = visitor.visit(content(d))
            if child.anyView is _TupleView {
                child.children.forEach(closure)
                return
            }
            closure(child)
        }
    }
}
extension ForEach: HasContainerContentSize { }
