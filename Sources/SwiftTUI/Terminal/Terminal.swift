//
//  Terminal.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/17.
//

import Foundation

internal struct Terminal {
    // See: https://misc.flogisoft.com/bash/tip_colors_and_formatting
    static internal func colorize(color: Color.Value, content: SwiftTUIContentType) -> SwiftTUIContentType {
        let escapeSequence = "\u{001B}" // \e
        let start = "\(escapeSequence)["
        let end = "\(escapeSequence)[0m"
        return start + "\(color)" + "m" + content + end
    }
}
