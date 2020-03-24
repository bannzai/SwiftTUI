//
//  Cursor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/07.
//

import Foundation
import cncurses

public struct Cursor {
    internal private(set) var x: PhysicalDistance = 0
    internal private(set) var y: PhysicalDistance = 0
    
    fileprivate init() { }
}

internal extension Cursor {
    mutating func moveTo(x: PhysicalDistance, y: PhysicalDistance) {
        self.x = x
        self.y = y
        let result = cncurses.move(Int32(y), Int32(x))
        debugLogger.debug(userInfo: "move: \(result), x: \(x), y: \(y)")
    }
    mutating func move(x: PhysicalDistance, y: PhysicalDistance) {
        let _x = self.x + x
        let _y = self.y + y
        moveTo(x: _x, y: _y)
    }
}

internal var sharedCursor = Cursor()
internal func drawPoint() -> Point {
    Point(x: sharedCursor.x, y: sharedCursor.y)
}
