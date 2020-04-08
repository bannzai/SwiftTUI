//
//  Logger.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import Foundation

internal protocol Logger {
    static var prefix: String { get }
    var loggerPath: URL { get }
}

fileprivate var limit = 20000
fileprivate var calledCount = 0
extension Logger {
    // NOTE: This project sometimes happen infinite loop.
    // Since DebugLogger is often used, we put in a process to stop the infinite loop.
    private func callStopper() {
        calledCount += 1
        if limit < calledCount {
            fatalError("Limited logger count")
        }
    }
    internal func log(
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
        let content = buildContent()
        //            debugPrint(content)
        guard let data = content.data(using: .utf8) else {
            fatalError("could not convert to byte strings for \(content)")
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

internal func createFileIfNotExists(path: String) {
    if FileManager.default.fileExists(atPath: path) {
        return
    }
    FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
}

