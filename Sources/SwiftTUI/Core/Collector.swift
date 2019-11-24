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
    mutating func collect(with next: Self)
}

extension SwiftTUIContentType: Collector {
    public static func empty() -> String { SwiftTUIContentType() }
    public mutating func collect(with next: String) {
        append(contentsOf: next)
    }
}

extension Array: Collector where Element: Collector {
    public static func empty() -> Array<Element> { [] }
    public mutating func collect(with next: Array<Element>) {
        append(contentsOf: next)
    }
}
