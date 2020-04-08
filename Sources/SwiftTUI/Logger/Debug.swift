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

        var loggerPath: URL {
            if let path = ProcessInfo.processInfo.environment["DEBUG_LOGGER_PATH"].flatMap({ URL(string: $0) }) {
                return path
            }
            return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("swifttui.logger.d").appendingPathComponent("swifttui.debug.log")
        }

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
