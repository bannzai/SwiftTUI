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
    internal var isUserDefinedView: Bool = false
    
    internal var listType: ViewVisitorListOption = .default
    internal var alignment: Alignment = .default
    internal lazy var spacing: PhysicalDistance = listType.defaultSpace
    internal var proposedSize: Size = .zero

    internal weak var beforeRelation: ViewGraph?
    internal var afterRelation: ViewGraph?
    
    internal var rect: Rect = Rect(origin: .zero, size: .zero)

    internal func addChild(_ node: ViewGraph) {
        children.insert(node)
        node.parent = self
        
        node.alignment = alignment
        node.spacing = spacing
        node.listType = listType
    }
    
    internal func addRelation(_ node: ViewGraph) {
        afterRelation = node
        node.beforeRelation = self
    }
    
    internal var isRoot: Bool {
        parent == nil
    }
    
    internal var anyView: Any {
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
        case _:
            break
        }
        
        if view.isPrimitive {
            fatalError("It is mean about forgot implement calc size of Primitive View")
        }
        
        let graph = ViewGraphImpl(view: view)
        current?.addChild(graph)
        let keepCurrent = current
        defer { current = keepCurrent }
        current = graph
        graph.addChild(visit(view: view.body))
        graph.isUserDefinedView = true
        return graph
    }
}

extension ViewGraph: ViewRectSetAcceptable {
    func accept(visitor: ViewRectSetVisitor, with argument: ViewRectSetVisitor.Argument) -> ViewRectSetVisitor.VisitResult {
        fatalError()
    }
}

// e.g) Text, Padding
internal protocol HasContentSize {
    func contentSize(viewGraph: ViewGraph, visitor: ViewSizeVisitor) -> Size
}

extension ViewGraph: ViewSizeAcceptable {
    func accept(visitor: ViewSizeVisitor) -> ViewSizeVisitor.VisitResult {
        if isRoot {
            proposedSize = mainScreen.bounds.size
        }
        children.forEach { $0.proposedSize = proposedSize }

        if let view = anyView as? HasContentSize {
            let size = view.contentSize(viewGraph: self, visitor: visitor)
            rect.size = size
            return size
        }

        if !children.isEmpty {
            return children
                .map { $0.accept(visitor: visitor) }
                .reduce(.zero) { Size(width: $0.width + $1.width, height: $0.height + $1.height) }
        }
        
        fatalError("Unexpected pattern of \(self)")
    }
}

extension Text: HasContentSize {
    private func calcTextSize(proposedWidth: PhysicalDistance) -> Size {
        let contents = content.split(separator: "\n").map { String($0) }
        let baseHeight = contents.count
        guard let maxWidthString = contents.max (by: { $0.width < $1.width }) else {
            return Size(width: proposedWidth, height: baseHeight)
        }
        let width = maxWidthString.width
        if width > proposedWidth {
            let lineBreakCount = width / proposedWidth
            return Size(width: width, height: baseHeight + lineBreakCount)
        }
        return Size(width: width, height: baseHeight)
    }
    func contentSize(viewGraph: ViewGraph, visitor: ViewSizeVisitor) -> Size {
        let size = calcTextSize(proposedWidth: viewGraph.proposedSize.width)
        return size
    }
}

extension TupleView: HasContentSize {
    func contentSize(viewGraph: ViewGraph, visitor: ViewSizeVisitor) -> Size {
        switch viewGraph.listType {
        case .vertical:
            let children = viewGraph.children
            var allocableHeight: PhysicalDistance = viewGraph.proposedSize.height - (children.count - 1) * viewGraph.spacing
            var maxElementWidth: PhysicalDistance = 0
            children.enumerated().forEach { (offset, element) in
                let provisionalElementHeight: PhysicalDistance = allocableHeight / (children.count - offset)
                let elementProposedSize = Size(width: viewGraph.proposedSize.width, height: max(provisionalElementHeight, 0))
                element.proposedSize = elementProposedSize
                
                let elementSize = element.accept(visitor: visitor)
                maxElementWidth = max(maxElementWidth, elementSize.width)
                allocableHeight -= elementSize.height
            }
            
            maxElementWidth = min(maxElementWidth, viewGraph.proposedSize.width)
            
            switch allocableHeight {
            case let allocableHeight where allocableHeight < 0:
                return Size(width: maxElementWidth, height: viewGraph.proposedSize.height + abs(allocableHeight))
            case let allocableHeight where allocableHeight > 0:
                return Size(width: maxElementWidth, height: viewGraph.proposedSize.height - allocableHeight)
            case _:
                return Size(width: maxElementWidth, height: viewGraph.proposedSize.height)
            }
        case .horizontal:
            return .zero
//            fatalError()
        }
    }
}
