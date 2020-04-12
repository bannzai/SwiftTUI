//
//  ViewGraph+SetRect.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/03/31.
//

import Foundation

extension ViewGraph: ViewSetRectVisitorAcceptable {
    func accept(visitor: ViewSetRectVisitor) -> ViewSetRectVisitor.VisitResult {
        let keepCurrent = visitor.current
        defer { visitor.current = keepCurrent }
        visitor.current = self
        defer {
            if isRoot {
                acceptSetDimensions(visitor: visitor)
                acceptSetPosition(visitor: visitor)
                acceptSetContainerSize(visitor: visitor)
            }
        }
        
        if isRoot {
            setProposedSizeIfFirst(mainScreen.bounds.size)
        }
        parent.map {
            setProposedSizeIfFirst($0.proposedSize)
        }

        if isModifiedContent {
            guard let view = anyView as? HasAnyModifier else {
                fatalError("isModifiedContent is true but it has not anyModifier \(self)")
            }
            if let modifier = view.anyModifier as? _PaddingLayout {
                modifier.modify(for: self, visitor: visitor)
                return
            }
            if let modifier = view.anyModifier as? _BorderModifier {
                modifier.modify(for: self, visitor: visitor)
                return
            }
            if let modifier = view.anyModifier as? _FrameLayout {
                modifier.modify(for: self, visitor: visitor)
                return
            }
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
        
        if anyView is ViewSetRectVisitorSkip {
            return
        }
        
        fatalError("unexpected pattern \(self)")
    }
}

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

extension ViewGraph {
    private func acceptSetDimensions(visitor: ViewSetRectVisitor) {
        let keepCurrentContainer = visitor.currentContainerGraph
        defer { visitor.currentContainerGraph = keepCurrentContainer }
        if anyView is ContainerViewType {
            visitor.currentContainerGraph = self
        }
        
        children.forEach { $0.acceptSetDimensions(visitor: visitor) }
        
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
            // NOTE: Maybe VStack or HStack
            parent?.rect.size = rect.size
            return
        }
        
        children.forEach { $0.acceptSetContainerSize(visitor: visitor) }
        
        if children.isEmpty {
            return
        }
        
        if !isUserDefinedView {
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
            let lineBreakCount = PhysicalDistance(roundf(Float(width) / Float(proposedWidth)))
            return Size(width: proposedWidth, height: lineBreakCount)
        }
        return Size(width: width, height: baseHeight)
    }
    func intrinsicContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size {
        if viewGraph.proposedSize.width == 0 {
            return .zero
        }
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
            var allocableHeight: PhysicalDistance = viewGraph.proposedSize.height - (viewGraph.rendableChildren.count - 1) * viewGraph.spacing
            var maxElementWidth: PhysicalDistance = 0
            viewGraph.rendableChildren.enumerated().forEach { (offset, element) in
                let provisionalElementHeight: PhysicalDistance = allocableHeight / (viewGraph.rendableChildren.count - offset)
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

