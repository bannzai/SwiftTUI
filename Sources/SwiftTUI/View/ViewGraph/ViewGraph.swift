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
    internal var children: [ViewGraph] = []
    internal var isUserDefinedView: Bool = false
    internal var isModifiedContent: Bool = false
    internal var isContainerType: Bool { anyView is ContainerViewType }
    internal var isRendableType: Bool { anyView is Rendable }
    internal var isUserDefinedModifierContent: Bool { anyView is UserDefinedViewModifierContent }
    
    internal var listType: ViewVisitorListOption = .default
    internal var alignment: Alignment = .default
    internal lazy var spacing: PhysicalDistance = listType.defaultSpace
    internal lazy var dimensions: ViewDimensions = ViewDimensions(graph: self)
    internal var rect: Rect = Rect(origin: .zero, size: .zero)
    internal var proposedSize: Size = .zero

    func _extractUserDefinedModifierContentChild(root: ViewGraph) -> ViewGraph? {
        if isUserDefinedModifierContent && root !== self {
            return self
        }
        if children.isEmpty {
            return nil
        }
        return children.compactMap { $0._extractUserDefinedModifierContentChild(root: root) }.first
    }
    internal func extractUserDefinedModifierContentChild() -> ViewGraph? {
        _extractUserDefinedModifierContentChild(root: self)
    }
    internal func alreadyMarkedProposedSize() -> Bool {
        return proposedSizeMarker.isMarked(graph: self)
    }
    internal func setProposedSizeIfFirst(_ size: Size) {
        if proposedSizeMarker.isMarked(graph: self) {
            return
        }
        proposedSizeMarker.mark(graph: self)
        proposedSize = size
    }
    
    internal func inheritProperties(to child: ViewGraph) {
        child.alignment = alignment
        child.spacing = spacing
        child.listType = listType
    }
    
    internal func addChild(_ node: ViewGraph) {
        assert(self !== node)
        if children.contains(where: { $0 === node }) {
            return
        }
        if node is ViewGraphNone {
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
    
    internal var rendableChildren: [ViewGraph] {
        let rendableChildren = children.compactMap { $0._extractRendableChlid(root: self) }
        return rendableChildren
    }
     
    internal var nearContainerParent: ViewGraph? {
        guard let parent = parent else {
            return nil
        }
        if parent.isContainerType  {
            return parent
        }
        return parent.nearContainerParent
    }

    internal func copy() -> Self {
        fatalError()
    }
}

extension ViewGraph {
    func printTree() {
        print(buildRecursiveDebugContent(from: 0))
    }
    func buildRecursiveDebugContent(from level: Int) -> String {
        var content = ""
        content += "- " + debugContent(level: level) + "\n"
        if children.isEmpty {
            return content
        }
        for (_, child) in children.enumerated() {
            content += space(level: level + 1) + "|" + child.buildRecursiveDebugContent(from: level + 1)
        }
        return content
    }
    private func space(level: Int) -> String {
        var indent = ""
        stride(from: 0, through: level, by: 1).forEach { i in
            indent += " "
        }
        return indent
    }
    private func debugContent(level: Int) -> String {
        return "\(type(of: self.anyView))"
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

extension ViewGraph: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: ViewGraph, rhs: ViewGraph) -> Swift.Bool {
        lhs.identifier == rhs.identifier
    }
}
