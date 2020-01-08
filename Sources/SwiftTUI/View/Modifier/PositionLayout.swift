//
//  PositionLayout.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/01/08.
//

import Foundation

@frozen public struct _PositionLayout {
    public var position: Point
    @inlinable public init(position: Point) {
        self.position = position
    }
    
    public typealias Body = Swift.Never
}

extension _PositionLayout: ViewModifier { }

extension View {
    @inlinable public func position(_ position: Point) -> some View {
        return modifier(_PositionLayout(position: position))
    }
    
    @inlinable public func position(x: PhysicalDistance = 0, y: PhysicalDistance = 0) -> some View {
        return position(Point(x: x, y: y))
    }
}

internal protocol HasFixedPosition {
    func fixedPosition(viewGraph: ViewGraph, visitor: ViewPositionVisitor) -> ViewPositionVisitor.VisitResult
}

extension ModifiedContent: HasFixedPosition where Modifier == _PositionLayout {
    func fixedPosition(viewGraph: ViewGraph, visitor: ViewPositionVisitor) -> ViewPositionVisitor.VisitResult {
        let position = modifier.position
        viewGraph.rect.origin = position
        return position
    }
}

