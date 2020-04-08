//
//  Debug.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/17.
//

import Foundation

// NOTE: prevent infite loop
internal struct Debug {
    internal struct Logger: SwiftTUI.Logger {
        static let prefix = "DEBUG: "
        static let filename: String = "swifttui.debug.log"

        internal func debug(
            function: String = #function,
            file: String = #file,
            line: Int = #line,
            userInfo: CustomDebugStringConvertible? = nil
        ) {
            log(function: function, file: file, line: line, userInfo: userInfo)
        }
    }
    
    internal struct EnvironmentVariables {
        static var isRunOnXcode: Bool { ProcessInfo.processInfo.environment["DEBUG_ON_XCODE"] == "true" }
    }
}


let debugLogger = Debug.Logger()
