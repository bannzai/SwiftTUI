//
//  Application.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation
import cncurses

fileprivate let sharedQueue = MainQueue()
internal func message(with event: MainQueue.Event) {
    sharedQueue.message(with: event)
}

// Application is management SwiftTUI process with root view
public final class Application<Root: View> {
    internal let screen: Screen
    internal let viewController: HostViewController<Root>
    public init(viewController: HostViewController<Root>) {
        self.viewController = viewController
        self.screen = Screen()
        sharedQueue.inject(drawable: self.viewController)
    }
    
    internal var isAlreadyRun = false
    public func run() {
        if isAlreadyRun {
            fatalError("Unexpected call this function of #Application.run")
        }
        isAlreadyRun = true

        defer {
            screen.dispose()
        }
        screen.setup()
        setupInputHandler()

        RunLoop.main.run()
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
                    self.screen.cursor.move(x: 10, y: 10)
                case _:
                    break
                }
            case _:
                break
            }
        }
    }
}
