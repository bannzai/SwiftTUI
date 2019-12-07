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

        private var loggerPath: URL {
            if let path = ProcessInfo.processInfo.environment["DEBUG_LOGGER_PATH"].flatMap({ URL(string: $0) }) {
                return path
            }
            return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("swifttui.logger.d").appendingPathComponent("swifttui.debug.log")
        }

        // NOTE: This project sometimes happen infinite loop.
        // Since DebugLogger is often used, we put in a process to stop the infinite loop.
        private func callStopper() {
            calledCount += 1
            if limit < calledCount {
                fatalError("Limited logger count")
            }
        }
        
        internal func debug(
            function: String = #function,
            file: String = #file,
            line: Int = #line,
            userInfo: CustomDebugStringConvertible? = nil
        ) {
            callStopper()
            
            func buildContent() -> String {
                switch userInfo {
                case nil:
                    return "\(Debug.Logger.prefix) function: \(function), file: \(file), line: \(line)\n"
                case let userInfo?:
                    return "\(Debug.Logger.prefix) function: \(function), file: \(file), line: \(line), userInfo: \(userInfo)\n"
                }
            }
            
            createFileIfNotExists(path: loggerPath.absoluteString)
            guard let stream = OutputStream(toFileAtPath: loggerPath.absoluteString, append: true) else {
                fatalError("could not open debug logger file stream. path: \(loggerPath)")
            }
            guard let data = buildContent().data(using: .utf8) else {
                fatalError("could not convert to byte strings for \(buildContent())")
            }
            
            stream.open()
            defer {
                stream.close()
            }
            _ = data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> Int in
                let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
                return stream.write(bufferPointer.baseAddress!, maxLength: data.count)
            }
        }
    }
    
    internal struct EnvironmentVariables {
        static var isRunOnXcode: Bool { ProcessInfo.processInfo.environment["DEBUG_ON_XCODE"] == "true" }
    }
}


let debugLogger = Debug.Logger()
