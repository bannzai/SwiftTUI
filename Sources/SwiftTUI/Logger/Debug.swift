//
//  Debug.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/17.
//

import Foundation

// NOTE: prevent infite loop
fileprivate var limit = 100
fileprivate var calledCount = 0
internal struct Debug {
    internal struct Logger {
        static let prefix = "DEBUG: "

        private var loggerBasePath: URL {
            ProcessInfo.processInfo.environment["DEBUG_LOGGER_PATH"].flatMap { URL(string: $0) } ?? FileManager.default.homeDirectoryForCurrentUser
        }
        private var loggerPath: URL {
            loggerBasePath.appendingPathComponent("swifttui.logger.d").appendingPathComponent("swifttui.debug.log")
        }
        func debug(
            function: String = #function,
            file: String = #file,
            line: Int = #line,
            userInfo: CustomDebugStringConvertible? = nil
        ) {
                    calledCount += 1
                    if limit < calledCount {
                        fatalError("Limited logger count")
                    }
                    switch userInfo {
                    case nil:
                        try! "\(Debug.Logger.prefix) function: \(function), file: \(file), line: \(line)"
                            .write(to: loggerPath, atomically: true, encoding: .utf8)
                    case let userInfo?:
                        try! "\(Debug.Logger.prefix) function: \(function), file: \(file), line: \(line), userInfo: \(userInfo)"
                            .write(to: loggerPath, atomically: true, encoding: .utf8)
                    }
        }
    }
    
    internal struct EnvironmentVariables {
        static var isRunOnXcode: Bool { ProcessInfo.processInfo.environment["DEBUG_ON_XCODE"] == "true" }
    }
}


let debugLogger = Debug.Logger()
