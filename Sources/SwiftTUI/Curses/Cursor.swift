//
//  Cursor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/07.
//

import Foundation
import cncurses

internal protocol Cursor {
    var x: PhysicalDistance { get }
    var y: PhysicalDistance { get }
    
    mutating func moveTo(point: Point)
    mutating func moveTo(x: PhysicalDistance, y: PhysicalDistance)
    mutating func move(x: PhysicalDistance, y: PhysicalDistance)
}

internal struct CursorImpl {
    internal var x: PhysicalDistance = 0
    internal var y: PhysicalDistance = 0
    
    fileprivate init() { }
}

extension CursorImpl: Cursor {
    mutating func moveTo(point: Point) {
        moveTo(x: point.x, y: point.y)
    }
    mutating func moveTo(x: PhysicalDistance, y: PhysicalDistance) {
        debugLogger.debug(userInfo: "x: \(x), y: \(y)")
        self.x = x
        self.y = y
        cncurses.move(Int32(y), Int32(x))
    }
    mutating func move(x: PhysicalDistance, y: PhysicalDistance) {
        let _x = self.x + x
        let _y = self.y + y
        moveTo(x: _x, y: _y)
    }
}

internal var sharedCursor: Cursor = CursorImpl()
internal func drawPoint() -> Point {
    Point(x: sharedCursor.x, y: sharedCursor.y)
}
