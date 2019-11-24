//
//  Contentable.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/24.
//

import Foundation

// FIXME: Using more generics protocol. e.g) See also, deleted commit 0c202caafabc48ef3e18b01d65d046f58069423e
public protocol Collector {
    static func empty() -> SwiftTUIContentType
    mutating func collect(with next: SwiftTUIContentType)
}

public protocol Contentable: Collector {
    func content() -> SwiftTUIContentType
}
