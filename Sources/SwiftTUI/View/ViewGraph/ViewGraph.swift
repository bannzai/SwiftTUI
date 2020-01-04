//
//  ViewGraph.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

public class ViewGraph: SwiftTUI.View {
    internal lazy private(set) var identifier: ObjectIdentifier = .init(self)
    
    internal weak var parent: ViewGraph?
    internal var children: Set<ViewGraph> = []
    
    internal weak var beforeRelation: ViewGraph?
    internal var afterRelation: ViewGraph?
    
    internal var rect: Rect = Rect(origin: .zero, size: .zero)
    
    internal func addChild(_ node: ViewGraph) {
        children.insert(node)
        node.parent = self
    }
    
    internal func addRelation(_ node: ViewGraph) {
        afterRelation = node
        node.beforeRelation = self
    }
    
    internal var isRoot: Bool {
        parent == nil
    }
    
    internal var anyBody: Any {
        fatalError()
    }
}

public final class ViewGraphImpl<View: SwiftTUI.View>: ViewGraph {
    internal let view: View
    internal init(view: View) {
        self.view = view
    }
    
    public var body: some SwiftTUI.View {
        view.body
    }
    
    override var anyBody: Any {
        body
    }
}

extension ViewGraph: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: ViewGraph, rhs: ViewGraph) -> Swift.Bool {
        lhs.identifier == rhs.identifier
    }
}

public final class ViewGraphSetVisitor {
    internal var current: ViewGraph? = nil
    internal init() { }
    
    internal func visit<T: View>(view: T) -> ViewGraph {
        switch view {
        case let tuple as ContainerViewGraphSetAcceptable:
            return tuple.accept(visitor: self)
        case let modifier as ViewGraphSetAttributeAcceptable:
            return modifier.accept(visitor: self)
        case let view as ViewGraphSetAcceptable:
            return view.accept(visitor: self)
        }
    }
}

extension ViewGraph: ViewRectSetAcceptable {
    func accept(visitor: ViewRectSetVisitor, with argument: ViewRectSetVisitor.Argument) -> ViewRectSetVisitor.VisitResult {
        fatalError()
    }
}

// e.g) Text, Padding
internal protocol HasContentSize {
    func contentSize(viewGraph: ViewGraph) -> Size
}

extension ViewGraph: ViewSizeAcceptable {
    func accept(visitor: ViewSizeVisitor, with argument: ViewSizeVisitor.Argument) -> ViewSizeVisitor.VisitResult {
        if isRoot {
            return rect.size
        }
        
        if let body = anyBody as? HasContentSize {
            let size = body.contentSize(viewGraph: self)
            rect.size = size
            return size
        }
        
        if !children.isEmpty {
            return children
                .map { $0.accept(visitor: visitor, with: argument) }
                .reduce(.zero) { Size(width: $0.width + $1.width, height: $0.height + $1.height) }
        }
        
        fatalError("Unexpected pattern of \(self)")
    }
}
