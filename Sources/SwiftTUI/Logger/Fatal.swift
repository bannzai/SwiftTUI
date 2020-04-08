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
            _ userInfo: String
        ) {
            log(function: function, file: file, line: line, userInfo: userInfo)
            fatalError(buildContent(function: function, file: file, line: line, userInfo: userInfo))
        }
        
    }
}


let fatalLogger = Fatal.Logger()
