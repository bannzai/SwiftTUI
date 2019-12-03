//
//  Application.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation

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
        
        viewController.draw()
        Terminal.File.input.readabilityHandler = { fileHandle in
            Terminal.File.output.write(fileHandle.availableData)
        }
        runLoop: while true { }
    }
}
