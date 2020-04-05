//
//  ModifierContent.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/28.
//

import Foundation

@frozen public struct ModifiedContent<Content, Modifier> where Content: View, Modifier: ViewModifier {
  public var content: Content
  public var modifier: Modifier
  @inlinable public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
}

extension ModifiedContent : Swift.Equatable where Content : Swift.Equatable, Modifier : Swift.Equatable {
    public static func == (lhs: ModifiedContent<Content, Modifier>, rhs: ModifiedContent<Content, Modifier>) -> Swift.Bool {
        lhs.content == rhs.content
    }
}

extension ModifiedContent: ViewContentAcceptable {
    internal func accept<V: ViewContentVisitor>(visitor: V) -> V.VisitResult {
        debugLogger.debug()
        if let modifier = modifier as? ViewContentAcceptable {
            modifier.accept(visitor: visitor)
            return
        }

        let body = modifier.body(content: _ViewModifier_Content())
        if let acceptable = body as? ViewContentAcceptable {
            acceptable.accept(visitor: visitor)
            return
        }

        fatalError("Unexpected ModifiedContent of \(type(of: self)), and modifier type \(type(of: modifier)), and content type \(type(of: content))")
    }
}

extension ModifiedContent: View {
    public typealias Body = Swift.Never
}

extension ModifiedContent: Rendable where Modifier: Rendable { }
extension ModifiedContent: ContainerViewType where Modifier: ContainerViewType { }
extension ModifiedContent: ViewGraphSetAttributeAcceptable {
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        let graph = ViewGraphImpl(view: self)
        visitor.current?.addChild(graph)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        let contengGraph = visitor.visit(content)
        graph.setModifier(contengGraph)
        if let modifier = modifier as? _FrameLayout {
            contengGraph.alignment = modifier.alignment
        }
        return graph
    }
}


extension View {
    @inlinable public func modifier<T: ViewModifier>(_ modifier: T) -> ModifiedContent<Self, T> {
        return .init(content: self, modifier: modifier)
    }
}

internal protocol HasAnyModifier {
    var anyModifier: Any { get }
}
extension ModifiedContent: HasAnyModifier {
    var anyModifier: Any { modifier }
}
