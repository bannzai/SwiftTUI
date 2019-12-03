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
struct DebugLogger {
    static let prefix = "DEBUG: "

    func debug(
        function: String = #function,
        file: String = #file,
        line: Int = #line,
        userInfo: CustomDebugStringConvertible? = nil
        ) {
//        calledCount += 1
//        if limit < calledCount {
//            fatalError("Limited logger count")
//        }
//        switch userInfo {
//        case nil:
//            print("\(DebugLogger.prefix) function: \(function), file: \(file), line: \(line)")
//        case let userInfo?:
//            print("\(DebugLogger.prefix) function: \(function), file: \(file), line: \(line), userInfo: \(userInfo)")
//        }
    }
}


let debugLogger = DebugLogger()
