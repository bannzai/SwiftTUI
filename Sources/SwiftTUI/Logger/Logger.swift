//
//  Logger.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import Foundation

internal protocol Logger {
    static var prefix: String { get }
    static var filename: String { get }
    var path: URL { get }
}

// NOTE: prevent infite loop
fileprivate var limit = 20000
fileprivate var calledCount = 0
extension Logger {
    // NOTE: This project sometimes happen infinite loop.
    // Since Logger is often used, we put in a process to stop the infinite loop.
    private func callStopper() {
        calledCount += 1
        if limit < calledCount {
            fatalError("Limited logger count")
        }
    }
    var path: URL {
        if let path = ProcessInfo.processInfo.environment["LOGGER_PATH"].flatMap({ URL(string: $0) }) {
            return path
        }
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("swifttui.logger.d").appendingPathComponent(Self.filename)
    }
    
    func buildContent(
        function: String,
        file: String,
        line: Int,
        userInfo: CustomDebugStringConvertible?
    ) -> String {
        switch userInfo {
        case nil:
            return "\(Self.prefix) function: \(function), file: \(file), line: \(line)\n"
        case let userInfo?:
            return "\(Self.prefix) function: \(function), file: \(file), line: \(line), userInfo: \(userInfo)\n"
        }
    }
    
    func log(
        function: String = #function,
        file: String = #file,
        line: Int = #line,
        userInfo: CustomDebugStringConvertible? = nil
    ) {
        callStopper()
        
        createFileIfNotExists(path: path.absoluteString)
        guard let stream = OutputStream(toFileAtPath: path.absoluteString, append: true) else {
            fatalError("could not open debug logger file stream. path: \(path)")
        }
        let content = buildContent(function: function, file: file, line: line, userInfo: userInfo)
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

