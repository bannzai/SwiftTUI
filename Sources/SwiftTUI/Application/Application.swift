//
//  Application.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation
import Darwin.ncurses
import cncurses

fileprivate let sharedQueue = MainQueue()
internal func message(with event: MainQueue.Event) {
    sharedQueue.message(with: event)
}

// Application is management SwiftTUI process with root view
public final class Application<Root: View> {

    // NOTE: ncurses root object name is `SCREEN`.
    // But defined type name is `WINDOW`.
    internal typealias Screen = UnsafeMutablePointer<cncurses.WINDOW>
    // NOTE: Keep screen
    internal var screen: Screen!
    // NOTE: access standard `Screen`. Maybe this is root screen.
    internal var standardScreen: Screen { stdscr }
    
    internal let viewController: HostViewController<Root>
    public init(viewController: HostViewController<Root>) {
        self.viewController = viewController
        sharedQueue.inject(drawable: self.viewController)
    }
    
    
    // reference: https://github.com/migueldeicaza/TermKit/blob/14bc403567e8bd4d13f01ad293797725d306b811/TermKit/Drivers/CursesDriver.swift#L67
    typealias get_wch_def = @convention(c) (UnsafeMutablePointer<Int32>) -> Int
    typealias add_wch_def = @convention(c) (UnsafeMutablePointer<m_cchar_t>) -> CInt
    var get_wch_fn : get_wch_def? = nil
    var add_wch_fn : add_wch_def? = nil
    
    internal var isAlreadyRun = false
    public func run() {
        if isAlreadyRun {
            fatalError("Unexpected call this function of #Application.run")
        }
        isAlreadyRun = true
        debugLogger.debug()
        
        initScreen()
        defer { disposeScreen() }
        enableNoBufferingMode()
        setupNoEchoOnWindow()
        callUseColor()
        enableCursor()
        configureColorPairs()
        setupKeypad()
        clear();
        setupInputHandler()
        
        let rtld_default = UnsafeMutableRawPointer(bitPattern: -2)
        
        let get_wch_ptr = dlsym(rtld_default, "get_wch")
        get_wch_fn = unsafeBitCast(get_wch_ptr, to: get_wch_def.self)
        
        let add_wch_ptr = dlsym(rtld_default, "add_wch")
        add_wch_fn = unsafeBitCast(add_wch_ptr, to: add_wch_def.self)

        RunLoop.main.run()
        
    }
    
    func setupInputHandler() {
        FileHandle.standardInput.readabilityHandler = { _ in
            let value = cncurses.getchar()
            if value == 27 {
                debugLogger.debug(userInfo: "value: \(value)")
                timeout(100)
                debugLogger.debug(userInfo: "value: \(cncurses.getchar())")
            } else {
                debugLogger.debug(userInfo: "value: \(value)")
            }
            fatalError("value: \(value)")
        }
    }
}


// MARK - Named ncurses functions
private extension Application {
    func initScreen() {
        screen = initscr()
    }
    func disposeScreen() {
        if !isendwin() {
            endwin()
        }
        delscreen(OpaquePointer(screen))
    }
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
