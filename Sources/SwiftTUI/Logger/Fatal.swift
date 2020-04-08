//
//  Fatal.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import Foundation

internal struct Fatal {
    internal struct Logger: SwiftTUI.Logger {
        static let prefix = "Fatal: "
        static let filename: String = "swifttui.fatal.log"
        func fatal(
            function: String = #function,
            file: String = #file,
            line: Int = #line,
            _ message: String
        ) -> Never {
            log(function: function, file: file, line: line, userInfo: message)
            return fatalError(buildContent(function: function, file: file, line: line, userInfo: message))
        }
        
    }
}


let fatalLogger = Fatal.Logger()
