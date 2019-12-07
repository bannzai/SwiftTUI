//
//  Cursor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/07.
//

import Foundation
import cncurses

public struct Cursor {
    internal var x: PhysicalDistance = 0
    internal var y: PhysicalDistance = 0
    
    internal var screen: Screen
    
    internal init(screen: Screen) {
        self.screen = screen
    }
}

internal extension Cursor {
    func moveTo(x: PhysicalDistance, y: PhysicalDistance) {
        screen.cursor.x = x
        screen.cursor.y = y
        cncurses.move(Int32(x), Int32(y))
    }
    func move(x: PhysicalDistance, y: PhysicalDistance) {
        let _x = screen.cursor.x + x
        let _y = screen.cursor.y + y
        moveTo(x: _x, y: _y)
    }
}
