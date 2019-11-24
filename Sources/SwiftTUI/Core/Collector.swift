//
//  Collector.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/10.
//

import Foundation

// TODO: Internal
public protocol Collector {
    static func empty() -> Self
    mutating func collect<T>(with content: T)
}

public protocol FlattenCollector: Collector, Sequence {
    
}

extension SwiftTUIContentType: Collector {
    public static func empty() -> SwiftTUIContentType { SwiftTUIContentType() }
    public mutating func collect<T>(with content: T) {
        if let content = content as? SwiftTUIContentType {
            append(contentsOf: content)
        }
    }
}

extension Array: Collector where Element: Collector {
    public static func empty() -> Array<Element> { [] }
    public mutating func collect<T>(with content: T) {
        if let content = content as? [Element] {
            append(contentsOf: content)
        }
        if let content = content as? Element {
            append(content)
        }
    }
}

extension Array: FlattenCollector where Element: Collector { }
