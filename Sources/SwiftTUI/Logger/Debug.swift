//
//  Debug.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/17.
//

import Foundation

struct DebugLogger {
    static let prefix = "DEBUG: "
    
    func debug(
        function: String = #function,
        file: String = #file,
        line: Int = #line,
        userInfo: CustomDebugStringConvertible? = nil
        ) {
        switch userInfo {
        case nil:
            print("\(DebugLogger.prefix) function: \(function), file: \(file), line: \(line)")
        case let userInfo?:
            print("\(DebugLogger.prefix) function: \(function), file: \(file), line: \(line), userInfo: \(userInfo)")
        }
    }
}


let debugLogger = DebugLogger()
