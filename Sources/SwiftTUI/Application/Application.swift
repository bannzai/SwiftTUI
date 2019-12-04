//
//  Application.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation
import Darwin.ncurses

fileprivate let sharedQueue = MainQueue()
internal func message(with event: MainQueue.Event) {
    sharedQueue.message(with: event)
}

// Application is management SwiftTUI process with root view
public final class Application<Root: View> {

    internal let viewController: HostViewController<Root>

    public init(viewController: HostViewController<Root>) {
        self.viewController = viewController
        sharedQueue.inject(drawable: self.viewController)
    }
    
    var isAlreadyRun = false
    
    public func run() {
        if isAlreadyRun {
            fatalError("Unexpected call this function of #Application.run")
        }
        isAlreadyRun = true
        debugLogger.debug()
        


        var count: Int32 = 0
        Terminal.File.output.fileHandler.write(
            "ioctl: \(ioctl(Terminal.File.input.descriptor, UInt(TIOCGETA), &count))\n".data(using: .utf8)!
        )
        Terminal.File.output.fileHandler.write("TIOCGETA: \(TIOCGETA)\n".data(using: .utf8)!)
        Terminal.File.output.fileHandler.write("count: \(count)\n".data(using: .utf8)!)

        freopen("/dev/null".cString(using: .utf8), "w", stdin)
        freopen("/dev/null".cString(using: .utf8), "w", stdout)
        FileHandle.standardInput.readabilityHandler = { _ in
            return
        }
        Darwin.noecho()
        inputLoop()
        RunLoop.main.run()
    }
    func inputLoop() {
        let data = readLine()
        print(data)
    }
}

