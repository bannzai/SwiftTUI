//
//  HasContainerContentSize.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/04/18.
//

import Foundation

internal protocol HasContainerContentSize {
    func containerContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size
}

extension HasContainerContentSize {
    func containerContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size {
        let rendableChildren = viewGraph.rendableChildren
        
        switch viewGraph.listType {
        case .vertical:
            var allocableHeight: PhysicalDistance = viewGraph.proposedSize.height - (rendableChildren.count - 1) * viewGraph.spacing
            var maxElementWidth: PhysicalDistance = 0
            rendableChildren.enumerated().forEach { (offset, element) in
                let provisionalElementHeight: PhysicalDistance = allocableHeight / (rendableChildren.count - offset)
                let elementProposedSize = Size(width: viewGraph.proposedSize.width, height: max(provisionalElementHeight, 0))
                element.proposedSize = elementProposedSize
                element.acceptSize(visitor: visitor)
                
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

