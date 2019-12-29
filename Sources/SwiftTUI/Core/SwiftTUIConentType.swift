//
//  SwiftTUIConentType.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/10.
//

import Foundation
import cncurses

// TODO: Internal
public typealias SwiftTUIContentType = String

// MARK: - Size
extension SwiftTUIContentType {
    internal var width: PhysicalDistance {
        map { $0.width }.reduce(0, +)
    }
}

fileprivate extension Character {
    static var cache: [Self: PhysicalDistance] = [:]
    func doCache(width: PhysicalDistance) -> PhysicalDistance {
        Self.cache[self] = width
        return width
    }
    var width: PhysicalDistance {
        if let cached = Self.cache[self] {
            return cached
        }
        if let ascii = asciiValue {
            switch ascii < 32 {
            case true:
                return doCache(width: 0)
            case false:
                return doCache(width: 1)
            }
        }
        let width = unicodeScalars
            .map { cncurses.wcwidth(Int32($0.value)) }
            .reduce(0) { max($0, $1) }
        return doCache(width: Int(width))
    }
}
