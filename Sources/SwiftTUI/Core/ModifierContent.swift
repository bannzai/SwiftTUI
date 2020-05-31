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
            debugLogger.debug()
            modifier.accept(visitor: visitor)
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

private protocol ForEachFindable {
    func findForEach() -> _ForEach?
}
extension ModifiedContent: ForEachFindable {
    func findForEach() -> _ForEach? {
        if let modified = content as? ForEachFindable {
            return modified.findForEach()
        }
        return content as? _ForEach
    }
}

extension ModifiedContent: Rendable where Modifier: Rendable { }
extension ModifiedContent: ContainerViewType where Modifier: ContainerViewType { }
extension ModifiedContent: ViewGraphSetAttributeAcceptable {
    private var isUserDefinedModifier: Bool {
        return !(modifier is Primitive)
    }
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        // TODO: Confirm truth
//        if let current = visitor.current, current.isContainerType {
//            if let forEach = findForEach() {
//                forEach.each(visitor: visitor) { (child) in
//                    // NOTE: escaping `if current = visitor.current, current.isContainerType` condition about ModifiedContent<ModifiedContent...> has ForEach
//                    visitor.current = ViewGraphNone()
//                    defer { visitor.current = current }
//                    let graph = visitor.visit(self)
//                    current.addChild(graph)
//
//                    var lastChild = graph
//                    while let next = lastChild.children.last {
//                        lastChild = next
//                    }
//                    lastChild.parent?.children.removeAll()
//                    lastChild.parent?.addChild(child)
//                }
//                return ViewGraphNone()
//            }
//        }

        let graph = ViewGraphImpl(view: self)
        visitor.current?.addChild(graph)
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = graph

        let contentGraph = visitor.visit(content)
        if isUserDefinedModifier {
            let bodyGraph = visitor.visit(modifier.body(content: _ViewModifier_Content()))
            graph.setModifierContent(bodyGraph)
            bodyGraph.extractUserDefinedModifierContentChild()!.addChild(contentGraph)
            return graph
        }

        graph.setModifierContent(contentGraph)
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

internal protocol _ModifiedContent { }
extension ModifiedContent: _ModifiedContent { }

extension ModifiedContent: ViewSetContentSizeVisitorAcceptable {
    func accept(visitor: ViewSetContentSizeVisitor) {
        let graph = visitor.current!
        graph.contentSize = graph.children.reduce(into: Size.zero) { (result, element) in
            result.width += element.contentSize.width
            result.height += element.contentSize.height
        }
    }
}

extension ModifiedContent: ViewSetPositionVisitorAcceptable {
    func accept(visitor: ViewSetPositionVisitor) {
        
    }
}
