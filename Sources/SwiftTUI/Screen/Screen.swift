//
//  Screen.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/07.
//

import Foundation
import cncurses

public class Screen {
    internal init() { }
    
    internal var windows: [Window] = []

    // NOTE: access stdscr. Maybe this is root screen.
    internal var keyWindow: Window { windows.first(where: { $0.window == stdscr })! }
    
    // NOTE: Cursor is shared on screen. Not `Window`.
    internal lazy var cursor: Cursor = Cursor(screen: self)
    
    internal var columns: PhysicalDistance { Int(cncurses.getmaxx(cncurses.stdscr)) }
    internal var rows: PhysicalDistance { Int(cncurses.getmaxy(cncurses.stdscr)) }
    internal var bounds: Rect {
        // NOTE: It can call after cncurses.initscr()
        Rect(origin: .zero, size: .init(width: columns, height: rows))
    }
}

private extension Screen {
    func append(window: Window) {
        windows.append(window)
    }
}

internal extension Screen {
    func setup() {
        if !windows.isEmpty {
            assertionFailure("duplicated call setup functions")
        }
        let window = Window(window: cncurses.initscr(), frame: bounds)
        window.setup()
        window.screen = self
        cncurses.refresh()
        append(window: window)
    }
    func dispose() {
        keyWindow.dispose()
        windows.remove(at: windows.firstIndex (where: { $0 === keyWindow })!)
    }
}
