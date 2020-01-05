//
//  Screen.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/07.
//

import Foundation
import cncurses

// Screen is defines the properties associated with a `console` based display
public class Screen {
    internal init() { }
    fileprivate static let shared: Screen = Screen()

    internal var columns: PhysicalDistance { PhysicalDistance(cncurses.getmaxx(cncurses.stdscr)) }
    internal var rows: PhysicalDistance { PhysicalDistance(cncurses.getmaxy(cncurses.stdscr)) }
    internal var width: PhysicalDistance { columns }
    internal var height: PhysicalDistance { rows }
    internal var bounds: Rect {
        // NOTE: It can call after cncurses.initscr()
        Rect(origin: .zero, size: .init(width: width, height: height))
    }
}

internal var mainScreen = Screen.shared
