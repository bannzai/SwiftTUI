//
//  Application.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation
import Darwin

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

        switch ProcessInfo.processInfo.environment["SWIFTTUI_SUB_PROCESS"] == nil {
        case true:
            let process = Process()
            process.launchPath = ProcessInfo.processInfo.arguments[0]
            var env = process.environment ?? [:]
            env["SWIFTTUI_SUB_PROCESS"] = "SWIFTTUI_SUB_PROCESS"
            process.environment = env
            
//            Terminal.File.input.readabilityHandler = { fileHandle in
//                Terminal.File.output.write(fileHandle.availableData)
//                sharedQueue.message(with: .empty)
//            }

            process.standardInput = FileHandle.nullDevice
            process.standardOutput = FileHandle.nullDevice
            process.launch()
            process.waitUntilExit()
        case false:
            viewController.draw()
            RunLoop.main.run()
        }
    }
}
