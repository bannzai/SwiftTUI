//
//  Assert.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/11.
//

import XCTest
import XCTest

public func XCTAssertAmbiguouseOrder<T>(_ expression1: @autoclosure () -> [T], _ expression2: @autoclosure () -> [T], _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where T : Equatable {
    func error() {
        var message = message()
        if message.isEmpty {
            message = "missing order a: \(a) between b \(b)"
        }
        XCTFail(message, file: file, line: line)
    }
    let a = expression1()
    let b = expression2()
    
    let large: [T]
    let small: [T]
    switch a.count > b.count {
    case true:
        large = a
        small = b
    case false:
        large = b
        small = a
    }
    
    var sCheckedOffset: Int = 0
    var lCheckedOffset: Int = 0
    for (sOffset, s) in small.enumerated() {
        if sOffset < sCheckedOffset {
            continue
        }
        sCheckedOffset = sOffset
        
        var exists: Bool = false
        for (lOffset, l) in large.enumerated() {
            if lOffset < lCheckedOffset {
                continue
            }
            lCheckedOffset = lOffset
            
            if s == l {
                exists = true
                break
            }
        }
        if !exists {
            error()
        }
    }
    
    if (sCheckedOffset + 1) != small.count {
        error()
    }
}
