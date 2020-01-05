//
//  Distance.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation

public typealias PhysicalDistance = Int

public struct Size {
    public static let zero = Size(width: 0, height: 0)
    
    public var width: PhysicalDistance
    public var height: PhysicalDistance
    public init(width: PhysicalDistance, height: PhysicalDistance) {
        self.width = width
        self.height = height
    }
}

extension Size: Equatable { }

public struct Point {
    public static let zero = Point(x: 0, y: 0)
    
    public var x: PhysicalDistance
    public var y: PhysicalDistance
    public init(x: PhysicalDistance, y: PhysicalDistance) {
        self.x = x
        self.y = y
    }
}

public struct Rect {
    internal static let zero = Rect(origin: .zero, size: .zero)
    public var origin: Point
    public var size: Size
    public init() {
        self.origin = .zero
        self.size = .zero
    }
    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
    public init(x: PhysicalDistance, y: PhysicalDistance, width: PhysicalDistance, height: PhysicalDistance) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}
