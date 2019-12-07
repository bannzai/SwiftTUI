//
//  Screen.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/07.
//

import Foundation
import cncurses

public struct Screen {
    public static let shared = Screen()
    private init() {
        screen = initscr()
    }
    
    // NOTE: ncurses root object name is `SCREEN`.
    // But defined type name is `WINDOW`.
    internal typealias _Screen = UnsafeMutablePointer<cncurses.WINDOW>
    // NOTE: Keep screen
    internal var screen: _Screen!
    
    // NOTE: access standard `Screen`. Maybe this is root screen.
    internal var standardScreen: _Screen { stdscr }
}


// MARK - Named ncurses functions
private extension Screen {
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
        keypad(standardScreen, returnRawKeyCode)
    }
}

// MARK: - Internal Named ncurses functions
internal extension Screen {
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
        delscreen(OpaquePointer(screen))
    }
}
