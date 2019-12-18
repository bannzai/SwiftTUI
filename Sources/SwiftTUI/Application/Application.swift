//
//  Application.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation
import cncurses

// Application is management SwiftTUI process with root view
public final class Application<Root: View> {
    internal let viewController: HostViewController<Root>
    public init(viewController: HostViewController<Root>) {
        self.viewController = viewController
    }
    
    internal var isAlreadyRun = false
    public func run() {
        if isAlreadyRun {
            fatalError("Unexpected call this function of #Application.run")
        }
        isAlreadyRun = true

        setup()
        defer {
            disposeKeyWindow()
        }
        setupInputHandler()
        viewController.window = keyWindow
        viewController.draw()

        RunLoop.main.run()
    }
    
    internal var windows: [Window] = []
    
    // NOTE: access stdscr. Maybe this is root screen.
    internal var keyWindow: Window { windows.first(where: { $0.window == stdscr })! }
}


private extension Application {
    func setup() {
        if !windows.isEmpty {
            assertionFailure("duplicated call setup functions")
        }
        let window = Window(window: cncurses.initscr(), frame: Screen.main.bounds)
        window.setup()
        cncurses.refresh()
        append(window: window)
    }
    func disposeKeyWindow() {
        let keyWindow = self.keyWindow
        windows.remove(at: windows.firstIndex (where: { $0 === keyWindow })!)
        keyWindow.dispose()
    }
    
    func setupInputHandler() {
        FileHandle.standardInput.readabilityHandler = { _ in
            let value: Int32 = cncurses.getch()
            debugLogger.debug(userInfo: "key typed value is \(value)")
            let keyType = KeyType(keyname: keyname(value))
            switch keyType {
            case .ctrl(let ctrlKey):
                debugLogger.debug(userInfo: "combination key of ctrl is \(ctrlKey.combinationKey)")
            case .alphameric(let alphameric):
                switch alphameric {
                case .a:
                    Screen.main.cursor.move(x: 10, y: 10)
                case _:
                    break
                }
            case _:
                break
            }
        }
    }
    func append(window: Window) {
        windows.append(window)
    }
}
