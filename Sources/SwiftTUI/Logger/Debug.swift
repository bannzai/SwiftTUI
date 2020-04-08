//
//  Debug.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/17.
//

import Foundation

internal struct Debug {
    internal struct Logger: SwiftTUI.Logger {
        static let prefix = "DEBUG: "
        static let filename: String = "swifttui.debug.log"
    }
}


let debugLogger = Debug.Logger()
