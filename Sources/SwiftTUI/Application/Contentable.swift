//
//  Contentable.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

public typealias SwiftTUIContentType = String

public protocol Contentable {
    func content() -> SwiftTUIContentType
}
