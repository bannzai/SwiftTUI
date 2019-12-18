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
    private init() { }
    private static let shared: Screen = Screen()
    internal static var main: Screen { shared }
    
    internal var windows: [Window] = []

    // NOTE: access stdscr. Maybe this is root screen.
    internal var keyWindow: Window { windows.first(where: { $0.window == stdscr })! }
    
    // NOTE: Cursor is shared on screen. Not `Window`.
    internal lazy var cursor: Cursor = Cursor(screen: self)
    
    internal var columns: PhysicalDistance { PhysicalDistance(cncurses.getmaxx(cncurses.stdscr)) }
    internal var rows: PhysicalDistance { PhysicalDistance(cncurses.getmaxy(cncurses.stdscr)) }
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
        let keyWindow = self.keyWindow
        windows.remove(at: windows.firstIndex (where: { $0 === keyWindow })!)
        keyWindow.dispose()
    }
}
