//
//  ViewGraph+SetRect.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/03/31.
//

import Foundation

extension ViewGraph: ViewSetRectVisitorAcceptable {
    func accept(visitor: ViewSetRectVisitor) {
        children.forEach { $0.accept(visitor: visitor) }
        acceptForSetDimensions(visitor: visitor)
        acceptSetContainerSize(visitor: visitor)
    }
}


// MARK: - Size
extension ViewGraph {
    func acceptSize(visitor: ViewSetRectVisitor) -> ViewSetRectVisitor.VisitResult {
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = self

        if isRoot {
            setProposedSizeIfFirst(mainScreen.bounds.size)
        }
        
        var next = self.parent
        while let parent = next {
            next = parent.parent
            if !parent.alreadyMarkedProposedSize() {
                continue
            }
            setProposedSizeIfFirst(parent.proposedSize)
        }
        
        if isModifiedContent {
            guard let view = anyView as? HasAnyModifier else {
                fatalError("isModifiedContent is true but it has not anyModifier \(self)")
            }
            if let modifier = view.anyModifier as? _PaddingLayout {
                modifier.modifySize(for: self, visitor: visitor)
                return
            }
            if let modifier = view.anyModifier as? _BorderModifier {
                modifier.modifySize(for: self, visitor: visitor)
                return
            }
            if let modifier = view.anyModifier as? _FrameLayout {
                modifier.modifySize(for: self, visitor: visitor)
                return
            }
        }
        
        if isContainerType {
            acceptSetContainerSize(visitor: visitor)
            return
        }
        if !children.isEmpty {
            children.forEach { $0.acceptSize(visitor: visitor) }
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

// MARK: - Position
extension ViewGraph {
    private static func extractAlignmentXValue(graph: ViewGraph, alignment: HorizontalAlignment) -> PhysicalDistance {
        switch graph.dimensions[explicit: alignment] {
        case nil:
            return alignment.id.defaultValue(in: graph.dimensions)
        case .some(let explicitValue):
            return explicitValue
        }
    }
    private static func extractAlignmentYValue(graph: ViewGraph, alignment: VerticalAlignment) -> PhysicalDistance {
        switch graph.dimensions[explicit: alignment] {
        case nil:
            return alignment.id.defaultValue(in: graph.dimensions)
        case .some(let explicitValue):
            return explicitValue
        }
    }
    private func acceptSetPosition(visitor: ViewSetRectVisitor) {
        let keepCurrentContainer = visitor.currentContainerGraph
        defer { visitor.currentContainerGraph = keepCurrentContainer }
        if anyView is ContainerViewType {
            visitor.currentContainerGraph = self
        }
        
        if children.isEmpty {
            return
        }

        children.forEach { $0.acceptSetPosition(visitor: visitor) }
        
        if isUserDefinedModifierContent {
            return
        }

        if isModifiedContent {
            guard let view = anyView as? HasAnyModifier else {
                fatalError("isModifiedContent is true but it has not anyModifier \(self)")
            }
            if view.anyModifier is _BorderModifier {
                // NOTE: it is already set position vai _BorderModifier.modify(graph:visitor:)
                return
            }
            if view.anyModifier is _PaddingLayout {
                // NOTE: it is already set position vai _PaddingLayout.modify(graph:visitor:)
                return
            }
            if view.anyModifier is _FrameLayout {
                rendableChildren.forEach { child in
                    let containerX = ViewGraph.extractAlignmentXValue(graph: self, alignment: child.alignment.horizontal)
                    let x = ViewGraph.extractAlignmentXValue(graph: child, alignment: child.alignment.horizontal)
                    child.rect.origin.x = containerX - x
                    
                    let containerY = ViewGraph.extractAlignmentYValue(graph: self, alignment: child.alignment.vertical)
                    let y = ViewGraph.extractAlignmentYValue(graph: child, alignment: child.alignment.vertical)
                    child.rect.origin.y = containerY - y
                }
                return
            }
        }
        
        switch listType {
        case .vertical:
            var maxX = PhysicalDistance(0)
            rendableChildren.enumerated().forEach { (offset, child) in
                let x = ViewGraph.extractAlignmentXValue(graph: child, alignment: alignment.horizontal)
                debugLogger.debug(userInfo: "self type \(type(of: self)) child type \(type(of: child)), self.alignment.horizontal: \(alignment.horizontal), x: \(x)")
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

// MARK: - Dimensions
extension ViewGraph {
    func acceptForSetDimensions(visitor: ViewSetRectVisitor) {
        let keepCurrentContainer = visitor.currentContainerGraph
        defer { visitor.currentContainerGraph = keepCurrentContainer }
        if anyView is ContainerViewType {
            visitor.currentContainerGraph = self
        }
        defer {
            if isRoot {
                acceptSize(visitor: visitor)
                acceptSetPosition(visitor: visitor)
            }
        }
        
        children.forEach { $0.accept(visitor: visitor) }
        
        guard let _ = visitor.currentContainerGraph else {
            return
        }
        
        if let view = anyView as? HasAnyModifier, let modifier = view.anyModifier as? _AlignmentWritingModifier {
            let computedValue = modifier.computeValue(dimensions)
            dimensions.set(key: modifier.key, value: computedValue)
            
            if let parent = parent, let view = parent.anyView as? HasAnyModifier, view.anyModifier is _AlignmentWritingModifier {
                parent.dimensions = dimensions
                return
            }
            
            extractRendableChlid()?.dimensions = dimensions
        }
    }
}

// MARK: - Container Size
extension ViewGraph {
    private func acceptSetContainerSize(visitor: ViewSetRectVisitor) {
        let keepCurrentContainer = visitor.currentContainerGraph
        defer { visitor.currentContainerGraph = keepCurrentContainer }
        if isContainerType {
            visitor.currentContainerGraph = self
        }
        if let view = anyView as? HasContainerContentSize {
            let size = view.containerContentSize(viewGraph: self, visitor: visitor)
            rect.size = size
            return
        }
        
        if children.isEmpty {
            return
        }
        children.forEach { $0.acceptSetContainerSize(visitor: visitor) }

        if !(isUserDefinedView || isUserDefinedModifierContent) {
            return
        }
        
        width: do {
            let minX = rendableChildren.map { $0.rect.origin.x }.min()!
            let maxX = rendableChildren.map { $0.rect.size.width }.max()!
            rect.size.width = maxX - minX
        }
        height: do {
            let minY = rendableChildren.map { $0.rect.origin.y }.min()!
            let maxY = rendableChildren.map { $0.rect.size.height }.max()!
            rect.size.height = maxY - minY
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
        
        if renderMarker.isMarked(graph: self) {
            return
        }
        renderMarker.mark(graph: self)
        
        sharedCursor.moveTo(point: positionToWindow())
        if let content = anyView as? ViewContentAcceptable {
            content.accept(visitor: visitor)
        }
    }
}

