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
