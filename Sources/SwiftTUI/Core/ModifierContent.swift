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

        if content is UserDefinedViewModifierContent {
            assert(visitor.current?.children.count == 0)
            visitor.current?.children.forEach(visitor.visit)
            return
        }
        if !(modifier is Primitive) {
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
    private var isUserDefinedModifier: Bool {
        return !(modifier is Primitive)
    }
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        if let forEach = content as? _ForEach, visitor.current != nil {
            var isFirst = true
            forEach.each(visitor: visitor) { (child) in
                let graph = ViewGraphImpl(view: self)
                graph.setModifier(child)

                if isFirst {
                    visitor.current?.addChild(child)
                    isFirst = false
                    return
                }

                if let nearContainer = visitor.current?.nearContainerParent {
                    let endIndex = nearContainer.children.endIndex
                    let lastChild = nearContainer.children[endIndex - 1]
                    let copiedChild = lastChild.copy()
                    nearContainer.addChild(copiedChild)

                    var furthest = copiedChild.children.last
                    while let next = furthest, !next.children.isEmpty {
                        furthest = next.children.last
                    }
                    if let furthestParent = furthest?.parent {
                        furthestParent.children.removeAll()
                        furthestParent.addChild(graph)
                    }
                }
            }
            return ViewGraphNone()
        }

        let graph = ViewGraphImpl(view: self)
        visitor.current?.addChild(graph)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph
        
        let contentGraph = visitor.visit(content)
        if isUserDefinedModifier {
            let bodyGraph = visitor.visit(modifier.body(content: _ViewModifier_Content()))
            graph.setModifier(bodyGraph)
            bodyGraph.extractUserDefinedModifierContentChild()!.addChild(contentGraph)
            return graph
        }
        
        graph.setModifier(contentGraph)
        if let modifier = modifier as? _FrameLayout {
            contentGraph.alignment = modifier.alignment
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
