//
//  TestHelper.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation
@testable import SwiftTUI


extension Terminal {
    static var isDisableColorize = false
    @_dynamicReplacement(for: colorize(color:content:))
    static internal func uncolorize(color: Color.Value, content: SwiftTUIContentType) -> SwiftTUIContentType {
        switch isDisableColorize {
        case true:
            return content
        case false:
            return Terminal._colorize(color: color, content: content)
        }
    }
}
