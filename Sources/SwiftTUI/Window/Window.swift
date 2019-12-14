//
//  Window.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/12/07.
//

import Foundation
import cncurses

public class Window {
    // NOTE: ncurses root object name is `SCREEN`.
    // But defined type name is `WINDOW`.
    internal typealias _Widnow = UnsafeMutablePointer<cncurses.WINDOW>
    // NOTE: Keep screen
    internal var window: _Widnow!
    
    weak var screen: Screen?
    
    internal init() {
        window = initscr()
    }
}

// MARK - Named ncurses functions
private extension Window {
    func enableNoBufferingMode() {
        // NOTE: Configure about immediately receive input keyevent
        cbreak()
    }
    func setupNoEchoOnWindow() {
        noecho()
    }
    func enableCursor() {
        let enable: Int32 = 1
        curs_set(enable)
    }
    func callUseColor() {
        start_color()
    }
    func configureColorPairs() {
        // NOTE: Range of 1 ~ (COLOR_PAIRS-1). If set 0, Setting foreground color is white and background color is black.
        // And It can not changed color pair.
        let pairNumber: Int16 = 1
        init_pair(pairNumber, Int16(COLOR_BLACK), Int16(COLOR_WHITE))
    }
    func setupKeypad() {
        // NOTE: If you set false, return character with escape sequence when input with function key
        let returnRawKeyCode = true
        keypad(window, returnRawKeyCode)
    }
}

// MARK: - Internal Named ncurses functions
internal extension Window {
    func setup() {
        enableNoBufferingMode()
        setupNoEchoOnWindow()
        callUseColor()
        enableCursor()
        configureColorPairs()
        setupKeypad()
        clear();
    }
    func dispose() {
        if !isendwin() {
            endwin()
        }
        delscreen(OpaquePointer(window))
    }
}