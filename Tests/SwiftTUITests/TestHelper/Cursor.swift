//
//  TestCursor.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/11.
//

import XCTest
@testable import SwiftTUI

class TestCursor: Cursor {
    internal var x: PhysicalDistance = 0 {
        didSet { xHistory.append(x) }
    }
    internal var y: PhysicalDistance = 0 {
        didSet { yHistory.append(y) }
    }
    var xHistory: [PhysicalDistance] = []
    var yHistory: [PhysicalDistance] = []
    
    func moveTo(point: Point) {
        self.x = point.x
        self.y = point.y
    }
    
    func moveTo(x: PhysicalDistance, y: PhysicalDistance) {
        self.x = x
        self.y = y
    }
    
    func move(x: PhysicalDistance, y: PhysicalDistance) {
        let _x = self.x + x
        let _y = self.y + y
        self.x = _x
        self.y = _y
    }
    
    func reset() {
        moveTo(x: 0, y: 0)
        xHistory.removeAll()
        yHistory.removeAll()
    }
}

