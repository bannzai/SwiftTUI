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

fileprivate typealias GetWideCharaterFunction = @convention(c) (UnsafeMutablePointer<Int32>) -> Int
fileprivate let rtld_default = UnsafeMutableRawPointer(bitPattern: -2)
fileprivate var get_wch: GetWideCharaterFunction = {
    let get_wch_ptr = dlsym(rtld_default, "get_wch")
    return unsafeBitCast(get_wch_ptr, to: GetWideCharaterFunction.self)
}()
// Application is management SwiftTUI process with root view
public final class Application<Root: View> {
    internal let screen: Screen
    internal let viewController: HostViewController<Root>
    public init(viewController: HostViewController<Root>) {
        self.viewController = viewController
        self.screen = Screen()
        sharedQueue.inject(drawable: self.viewController)
    }
    
    // reference: https://github.com/migueldeicaza/TermKit/blob/14bc403567e8bd4d13f01ad293797725d306b811/TermKit/Drivers/CursesDriver.swift#L67
    typealias add_wch_def = @convention(c) (UnsafeMutablePointer<m_cchar_t>) -> CInt
    var add_wch_fn : add_wch_def? = nil
    
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

        let add_wch_ptr = dlsym(rtld_default, "add_wch")
        add_wch_fn = unsafeBitCast(add_wch_ptr, to: add_wch_def.self)
        
        RunLoop.main.run()
    }
    
    func setupInputHandler() {
        FileHandle.standardInput.readabilityHandler = { _ in
            let value: Int32 = cncurses.getch()
            debugLogger.debug(userInfo: "key typed value is \(value)")
            let keyType = KeyType(keyname: keyname(value))
            switch keyType {
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
