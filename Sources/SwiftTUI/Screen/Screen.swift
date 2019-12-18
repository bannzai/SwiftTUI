//
//  Screen.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/07.
//

import Foundation
import cncurses

// Screen is defines the properties associated with a `console` based display
public final class Screen {
    private init() { }
    fileprivate static let shared: Screen = Screen()

    // NOTE: Cursor is shared on screen. Not `Window`.
    internal lazy var cursor: Cursor = Cursor(screen: self)
    
    internal var columns: PhysicalDistance { PhysicalDistance(cncurses.getmaxx(cncurses.stdscr)) }
    internal var rows: PhysicalDistance { PhysicalDistance(cncurses.getmaxy(cncurses.stdscr)) }
    internal var bounds: Rect {
        // NOTE: It can call after cncurses.initscr()
        Rect(origin: .zero, size: .init(width: columns, height: rows))
    }
}


internal var mainScreen = Screen.shared
