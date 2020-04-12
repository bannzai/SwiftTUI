//
//  ViewModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/28.
//

import Foundation

public struct _ViewModifier_Content<Modifier>: View where Modifier: ViewModifier {
    public typealias Body = Swift.Never
}

public protocol ViewModifier {
    associatedtype Body : View
    func body(content: Self.Content) -> Self.Body
    typealias Content = _ViewModifier_Content<Self>
}

extension ViewModifier where Body == Never {
    public func body(content: Self.Content) -> Self.Body {
        fatalError("body is never. received argument \(content)")
    }
}

extension _ViewModifier_Content: ViewGraphSetAcceptable {
    func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraphImpl(view: self)
        visitor.current?.addChild(graph)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        return graph
    }
}
