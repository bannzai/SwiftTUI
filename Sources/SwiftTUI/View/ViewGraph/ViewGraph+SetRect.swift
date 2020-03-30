//
//  ViewGraph+SetRect.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/03/31.
//

import Foundation

extension ViewGraph: ViewSetRectVisitorAcceptable {
    func accept(visitor: ViewSetRectVisitor) -> ViewSetRectVisitor.VisitResult {
        defer {
            if isRoot {
                accept_dimensions(visitor: visitor)
                accept_position(visitor: visitor)
                accept_container(visitor: visitor)
            }
        }
        if isRoot {
            proposedSize = mainScreen.bounds.size
        }
        
        children.forEach {
            $0.proposedSize = proposedSize
        }
        
        if !children.isEmpty {
            children.forEach { $0.accept(visitor: visitor) }
            let size = children
                .map { $0.rect.size }
                .reduce(.zero) { Size(width: $0.width + $1.width, height: $0.height + $1.height) }
            rect.size = size
            return
        }
        
        if let view = anyView as? HasIntrinsicContentSize {
            let size = view.intrinsicContentSize(viewGraph: self, visitor: visitor)
            rect.size = size
            return
        }
        fatalError("unexpected pattern \(self)")
    }
}

extension ViewGraph {
    private func accept_position(visitor: ViewSetRectVisitor) {
        if children.isEmpty {
            return
        }
        
        children.forEach { $0.accept_position(visitor: visitor) }
        
        switch listType {
        case .vertical:
            var maxX = PhysicalDistance(0)
            rendableChildren.enumerated().forEach { (offset, child) in
                let x: PhysicalDistance
                switch child.dimensions[explicit: child.alignment.horizontal] {
                case nil:
                    x = alignment.horizontal.id.defaultValue(in: child.dimensions)
                case .some(let explicitValue):
                    x = explicitValue
                }
                
                switch x {
                case let x where x < 0:
                    child.rect.origin.x = maxX + abs(x)
                case let x where x == 0:
                    child.rect.origin.x = maxX
                case let x where x > 0:
                    child.rect.origin.x = max(maxX - x, 0)
                    if x > maxX {
                        rendableChildren[0..<offset].forEach { $0.rect.origin.x += x - maxX }
                    }
                    maxX = max(x, maxX)
                case _:
                    fatalError()
                }
            }
            
            var beforeYPoistion: PhysicalDistance = 0
            rendableChildren.enumerated().forEach { (offset, child) in
                let padding = offset * listType.defaultSpace + beforeYPoistion
                child.rect.origin.y = padding
                beforeYPoistion = child.rect.origin.y + child.rect.size.height
            }
            
        case .horizontal:
            return
        }
    }
}

extension ViewGraph {
    private func accept_dimensions(visitor: ViewSetRectVisitor) {
        let keepCurrentContainer = visitor.currentContainerGraph
        defer { visitor.currentContainerGraph = keepCurrentContainer }
        if anyView is ContainerViewType {
            visitor.currentContainerGraph = self
        }
        
        children.forEach { $0.accept_dimensions(visitor: visitor) }
        
        guard let containerGraph = visitor.currentContainerGraph else {
            return
        }
        
        if let view = anyView as? HasAnyModifier, let modifier = view.anyModifier as? _AlignmentWritingModifier {
            let computedValue = modifier.computeValue(dimensions)
            dimensions.set(key: modifier.key, value: computedValue)
            
            // FIXME: maybe incorrect. how to use _combineExplicit??
            if let parent = parent, let view = parent.anyView as? HasAnyModifier, view.anyModifier is _AlignmentWritingModifier {
                horizontal: do {
                    containerGraph.alignment.horizontal.id._combineExplicit(childValue: computedValue, into: &parent.dimensions[explicit: modifier.key])
                }
                vertical: do {
                    containerGraph.alignment.vertical.id._combineExplicit(childValue: computedValue, into: &parent.dimensions[explicit: modifier.key])
                }
            }
            
        } else if let parent = parent, let view = parent.anyView as? HasAnyModifier, view.anyModifier is _AlignmentWritingModifier {
            dimensions = parent.dimensions
        }
    }
}

extension ViewGraph {
    private func accept_container(visitor: ViewSetRectVisitor) {
        if let view = anyView as? HasContainerContentSize {
            let size = view.containerContentSize(viewGraph: self, visitor: visitor)
            rect.size = size
            return
        }
        
        children.forEach { $0.accept_container(visitor: visitor) }
        
        if children.isEmpty {
            return
        }
        
        width: do {
            let minX = children.map { $0.rect.origin.x }.min()!
            let maxX = children.map { $0.rect.size.width }.max()!
            rect.size.width = maxX - minX
        }
        height: do {
            let minY = children.map { $0.rect.origin.y }.min()!
            let maxY = children.map { $0.rect.size.height }.max()!
            rect.size.height = maxY - minY
        }
    }
}

// e.g) Text, Padding
internal protocol HasIntrinsicContentSize {
    func intrinsicContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size
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
    func intrinsicContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size {
        let size = calcTextSize(proposedWidth: viewGraph.proposedSize.width)
        return size
    }
}

protocol HasContainerContentSize {
    func containerContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size
}

extension TupleView: HasContainerContentSize {
    func containerContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size {
        switch viewGraph.listType {
        case .vertical:
            var allocableHeight: PhysicalDistance = viewGraph.proposedSize.height - (viewGraph.children.count - 1) * viewGraph.spacing
            var maxElementWidth: PhysicalDistance = 0
            viewGraph.rendableChildren.enumerated().forEach { (offset, element) in
                let provisionalElementHeight: PhysicalDistance = allocableHeight / (viewGraph.children.count - offset)
                let elementProposedSize = Size(width: viewGraph.proposedSize.width, height: max(provisionalElementHeight, 0))
                element.proposedSize = elementProposedSize
                
                element.accept(visitor: visitor)
                maxElementWidth = max(maxElementWidth, element.rect.size.width + element.rect.origin.x)
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
