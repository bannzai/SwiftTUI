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
    internal private(set) var children: [ViewGraph] = []
    internal var isUserDefinedView: Bool = false
    internal var isModifiedContent: Bool = false
    internal var isContainerType: Bool { anyView is ContainerViewType }
    internal var isRendableType: Bool { anyView is Rendable }
    
    internal var listType: ViewVisitorListOption = .default
    internal var alignment: Alignment = .default
    internal lazy var spacing: PhysicalDistance = listType.defaultSpace
    internal lazy var dimensions: ViewDimensions = ViewDimensions(graph: self)
    internal var rect: Rect = Rect(origin: .zero, size: .zero)
    
    // MARK: - Dirty property for visitor flags
    internal var alreadyRender: Bool = false
    
    internal func inheritProperties(to child: ViewGraph) {
        child.alignment = alignment
        child.spacing = spacing
        child.listType = listType
    }
    
    internal func addChild(_ node: ViewGraph) {
        if children.contains(where: { $0 === node }) {
            return
        }
        children.append(node)
        node.parent = self
        inheritProperties(to: node)
    }

    internal func setModifier(_ modifierNode: ViewGraph) {
        isModifiedContent = true
        addChild(modifierNode)
    }
    
    internal func setCustomize(_ node: ViewGraph) {
        isUserDefinedView = true
        addChild(node)
    }
    
    internal var isRoot: Bool {
        parent == nil
    }
    
    internal var anyView: Any {
        fatalError()
    }
    
    private func _extractRendableChlid(root: ViewGraph) -> ViewGraph? {
        if isRendableType && root !== self {
            return self
        }
        if children.isEmpty {
            return nil
        }
        return children.compactMap { $0._extractRendableChlid(root: root) }.first
    }
    
    internal func extractRendableChlid() -> ViewGraph? {
        _extractRendableChlid(root: self)
    }
    
    internal var rendableChildren: [ViewGraph] {
        let rendableChildren = children.compactMap { $0._extractRendableChlid(root: self) }
        return rendableChildren
    }
     
    internal var nearContainerParent: ViewGraph? {
        guard let parent = parent else {
            return nil
        }
        return parent.nearContainerParent
    }
}

// MARK: - Utility
internal extension ViewGraph {
    func positionToWindow() -> Point {
        switch parent {
        case .some(let parent):
            let parentPosition = parent.positionToWindow()
            return Point(x: parentPosition.x + rect.origin.x  , y: parentPosition.y + rect.origin.y)
        case nil:
            return Point(x: rect.origin.x, y: rect.origin.y)
        }
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
    
    override var anyView: Any {
        view
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

internal final class ViewGraphSetVisitor: Visitor {
    internal var current: ViewGraph? = nil
    internal init() { }
    
    internal func visit<T: View>(_ view: T) -> ViewGraph {
        switch view {
        case let tuple as ContainerViewGraphSetAcceptable:
            return tuple.accept(visitor: self)
        case let modifier as ViewGraphSetAttributeAcceptable:
            return modifier.accept(visitor: self)
        case let view as ViewGraphSetAcceptable:
            return view.accept(visitor: self)
        case let _view as _View:
            return _view._wrappedViewForBuildGraph.accept(visitor: self)
        }
        
    }
}



extension ViewGraph: ViewContentAcceptable {
    func accept(visitor: ViewContentVisitor) {
        let keepCurrent = visitor.current
        visitor.current = self
        defer {
            visitor.current = keepCurrent
            children.forEach { $0.accept(visitor: visitor) }
            visitor.driver.restoreBackgroundColor()
        }
        
        if alreadyRender {
            return
        }
        alreadyRender = true

        sharedCursor.moveTo(point: positionToWindow())
        if let content = anyView as? ViewContentAcceptable {
            content.accept(visitor: visitor)
        }
    }
}
