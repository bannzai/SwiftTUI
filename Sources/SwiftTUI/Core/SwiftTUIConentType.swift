//
//  SwiftTUIConentType.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/10.
//

import Foundation

// TODO: Internal
public typealias SwiftTUIContentType = String

extension SwiftTUIContentType: Collector {
    public static func empty() -> SwiftTUIContentType { "" }
    public mutating func collect(with next: SwiftTUIContentType) { self += next }
}

extension SwiftTUIContentType: Contentable {
    public func content() -> SwiftTUIContentType {
        return self
    }
}
