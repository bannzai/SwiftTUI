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
    
    internal var listType: ViewVisitorListOption = .default
    internal var alignment: Alignment = .default
    internal lazy var spacing: PhysicalDistance = listType.defaultSpace
    internal lazy var dimensions: ViewDimensions = ViewDimensions(graph: self)
    internal var proposedSize: Size = .zero

    internal var rect: Rect = Rect(origin: .zero, size: .zero)
    
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
internal protocol HasIntrinsicContentSize {
    func intrinsicContentSize(viewGraph: ViewGraph, visitor: ViewIntrinsicContentSizeVisitor) -> Size
}

extension ViewGraph: ViewIntrinsicContentSizeAcceptable {
    func accept(visitor: ViewIntrinsicContentSizeVisitor) -> ViewIntrinsicContentSizeVisitor.VisitResult {
        if isRoot {
            proposedSize = mainScreen.bounds.size
        }
        
        children.forEach {
            $0.proposedSize = proposedSize
            _ = $0.accept(visitor: visitor)
        }

        if let view = anyView as? HasIntrinsicContentSize {
            let size = view.intrinsicContentSize(viewGraph: self, visitor: visitor)
            rect.size = size
            return size
        }

        return .zero
    }
}

extension ViewGraph: ViewPositionSetterAcceptable {
    func accept(visitor: ViewPositionSetVisitor) -> ViewPositionSetVisitor.VisitResult {
        if children.isEmpty {
            return
        }
        
        children.forEach { $0.accept(visitor: visitor) }
        
        if let view = anyView as? HasAnyModifier, view.anyModifier is _AlignmentWritingModifier {
            children[0].rect.origin.x = 0
            children[0].rect.origin.y = 0
            return
        }
        
        switch listType {
        case .vertical:
            var maxX = PhysicalDistance(0)
            children.enumerated().forEach { (offset, child) in
                let x: PhysicalDistance
                switch child.dimensions[explicit: child.alignment.horizontal] {
                case nil:
                    x = alignment.horizontal.id.defaultValue(in: child.dimensions)
                case .some(let explicitValue):
                    x = explicitValue
                }
                
                child.rect.origin.x = max(maxX - x, 0)
                if x > maxX {
                    children[0..<offset].forEach { $0.rect.origin.x += x - maxX }
                }
                maxX = max(x, maxX)
            }
            
            var beforeHeight: PhysicalDistance = 0
            children.enumerated().forEach { (offset, child) in
                let padding = offset * listType.defaultSpace + beforeHeight
                child.rect.origin.y = padding
                beforeHeight = child.rect.size.height
            }
            
        case .horizontal:
            return
        }
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

extension Text: HasIntrinsicContentSize {
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
    func intrinsicContentSize(viewGraph: ViewGraph, visitor: ViewIntrinsicContentSizeVisitor) -> Size {
        let size = calcTextSize(proposedWidth: viewGraph.proposedSize.width)
        return size
    }
}

protocol HasContainerContentSize {
    func containerContentSize(viewGraph: ViewGraph, visitor: ViewContainerContentSizeVisitor) -> Size
}

extension TupleView: HasContainerContentSize {
    func containerContentSize(viewGraph: ViewGraph, visitor: ViewContainerContentSizeVisitor) -> Size {
        switch viewGraph.listType {
        case .vertical:
            var allocableHeight: PhysicalDistance = viewGraph.proposedSize.height - (viewGraph.children.count - 1) * viewGraph.spacing
            var maxElementWidth: PhysicalDistance = 0
            viewGraph.children.enumerated().forEach { (offset, element) in
                let provisionalElementHeight: PhysicalDistance = allocableHeight / (viewGraph.children.count - offset)
                let elementProposedSize = Size(width: viewGraph.proposedSize.width, height: max(provisionalElementHeight, 0))
                element.proposedSize = elementProposedSize
                
                element.accept(visitor: visitor)
                maxElementWidth = max(maxElementWidth, element.rect.size.width)
                allocableHeight -= element.rect.size.height
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


extension ViewGraph: ViewContainerContentSizeAcceptable {
    func accept(visitor: ViewContainerContentSizeVisitor) -> ViewContainerContentSizeVisitor.VisitResult {

        if let view = anyView as? HasContainerContentSize {
            let size = view.containerContentSize(viewGraph: self, visitor: visitor)
            rect.size = size
            return
        }
        
        children.forEach { $0.accept(visitor: visitor) }

        if !children.isEmpty {
            return
        }
        
        let size = children
            .reduce(.zero) {
                Size(width: $0.width + $1.rect.size.width, height: $0.height + $1.rect.size.height)
        }
        rect.size = size
//        let maxX = children.map { $0.rect.origin.x }.max() ?? 0
//        let maxY = children.map { $0.rect.origin.y }.max() ?? 0
//        rect.size = Size(width: size.width + maxX, height: size.height + maxY)
    }
}
