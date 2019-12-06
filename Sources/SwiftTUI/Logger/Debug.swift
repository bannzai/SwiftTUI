//
//  Debug.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/17.
//

import Foundation

internal func createFileIfNotExists(path: String) {
    if FileManager.default.fileExists(atPath: path) {
        return
    }
    FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
}

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
        
        internal var loggerFile: FileHandle {
            try! FileHandle(forWritingTo: loggerPath)
        }
        
        internal func debug(
            function: String = #function,
            file: String = #file,
            line: Int = #line,
            userInfo: CustomDebugStringConvertible? = nil
        ) {
            calledCount += 1
            if limit < calledCount {
                fatalError("Limited logger count")
            }
            
            func buildContent() -> String {
                switch userInfo {
                case nil:
                    return "\(Debug.Logger.prefix) function: \(function), file: \(file), line: \(line)"
                case let userInfo?:
                    return "\(Debug.Logger.prefix) function: \(function), file: \(file), line: \(line), userInfo: \(userInfo)"
                }
            }
            
            createFileIfNotExists(path: loggerPath.absoluteString)
            loggerFile.seekToEndOfFile()
            loggerFile.write(buildContent().data(using: .utf8)!)
            try! loggerFile.close()
        }
    }
    
    internal struct EnvironmentVariables {
        static var isRunOnXcode: Bool { ProcessInfo.processInfo.environment["DEBUG_ON_XCODE"] == "true" }
    }
}


let debugLogger = Debug.Logger()
