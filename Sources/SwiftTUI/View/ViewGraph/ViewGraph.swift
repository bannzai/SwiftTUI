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
    internal var isModifiedContent: Bool = false
    
    internal var listType: ViewVisitorListOption = .default
    internal var alignment: Alignment = .default
    internal lazy var spacing: PhysicalDistance = listType.defaultSpace
    internal lazy var dimensions: ViewDimensions = ViewDimensions(graph: self)
    internal var proposedSize: Size = .zero

    internal var rect: Rect = Rect(origin: .zero, size: .zero)
    
    private func defineProperties(to child: ViewGraph) {
        child.alignment = alignment
        child.spacing = spacing
        child.listType = listType
    }
    
    internal func addChild(_ node: ViewGraph) {
        children.insert(node)
        node.parent = self
        defineProperties(to: node)
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
        case let _view as _View:
            return _view._wrappedViewForBuildGraph.accept(visitor: self)
        }
        
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
            let size = children
                .map { $0.accept(visitor: visitor) }
                .reduce(.zero) { Size(width: $0.width + $1.width, height: $0.height + $1.height) }
            rect.size = size
            return size
        }
        
        fatalError("Unexpected pattern of \(self)")
    }
}

extension ViewGraph: ViewPositionAcceptable {
    func extract(visitor: ViewPositionVisitor) -> (x: PhysicalDistance, y: PhysicalDistance) {
        let x: PhysicalDistance
        horizontal: switch dimensions[explicit: alignment.horizontal] {
        case nil:
            x = alignment.horizontal.id.defaultValue(in: dimensions)
        case .some(let explicitValue):
            let baseLine = alignment.horizontal.id.defaultValue(in: dimensions)
            x = baseLine - explicitValue
        }
        
        let y: PhysicalDistance
        vertical: switch dimensions[explicit: alignment.vertical] {
        case nil:
            y = alignment.vertical.id.defaultValue(in: dimensions)
        case .some(let explicitValue):
            let baseLine = alignment.vertical.id.defaultValue(in: dimensions)
            y = baseLine - explicitValue
        }
        return (x: x, y: y)
    }
    
    func accept(visitor: ViewPositionVisitor) -> ViewPositionVisitor.VisitResult {
        children.forEach { _ = $0.accept(visitor: visitor) }
        
        if let view = anyView as? HasFixedPosition {
            let position = view.fixedPosition(viewGraph: self, visitor: visitor)
            rect.origin = position
            return position
        }
        
        var xList: ContiguousArray<PhysicalDistance> = ContiguousArray(repeating: 0, count: children.count)
        var yList: ContiguousArray<PhysicalDistance> = ContiguousArray(repeating: 0, count: children.count)
        children.enumerated().forEach { (offset, child) in
            let (x, y) = child.extract(visitor: visitor)
            xList[offset] = x
            yList[offset] = y
        }
        
        let maxX = xList.max()!
        let maxY = yList.max()!
        children.enumerated().forEach { (offset, child) in
            child.rect.origin.x = maxX - xList[offset]
            child.rect.origin.y = maxY - yList[offset]
            
            child.rect.origin.x += alignment.horizontal.id.defaultValue(in: dimensions)
            child.rect.origin.y += alignment.vertical.id.defaultValue(in: dimensions)
            
        }

        return rect.origin
    }
}

extension ViewGraph: ViewDimensionsAcceptable {
    func decideAlignmentGuide(for values: (id: AlignmentID.Type, key: AlignmentKey)) -> ViewDimensionsVisitor.VisitResult {
        guard let view = anyView as? HasAnyModifier, let modifier = view.anyModifier as? _AlignmentWritingModifier else {
            children.forEach { _ = $0.decideAlignmentGuide(for: values) }
            return dimensions
        }
        
        if values.key == modifier.key {
            children.forEach { child in
                let childDimensions = child.decideAlignmentGuide(for: values)
                let childValue = childDimensions[explicit: values]
                switch childValue {
                case nil:
                    let computedValue = modifier.computeValue(dimensions)
                    dimensions.set(key: values.key, value: computedValue)
                case .some(let childValue):
                    values.id._combineExplicit(childValue: childValue, into: &dimensions[explicit: values])
                }
            }
        }
        return dimensions
    }
    
    func accept(visitor: ViewDimensionsVisitor) -> ViewDimensionsVisitor.VisitResult {
        horizontal: do {
            let id = alignment.horizontal.id
            let key = alignment.horizontal.key
            _ = decideAlignmentGuide(for: (id: id, key: key))
        }
        vertical: do {
            let id = alignment.vertical.id
            let key = alignment.vertical.key
            _ = decideAlignmentGuide(for: (id: id, key: key))
        }
        return dimensions
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
            fatalError()
        }
    }
}
