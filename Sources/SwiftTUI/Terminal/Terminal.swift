//
//  Terminal.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/17.
//

import Foundation

internal struct Terminal {
    
    // MARK: - Decorate Color
    // See: https://misc.flogisoft.com/bash/tip_colors_and_formatting
    struct ColorDecorate {
        static internal let escapeSequence = "\u{001B}" // NOTE: \e
        static internal let start = "\(escapeSequence)["
        static internal let end = "\(escapeSequence)[0m"
    }
    static internal func _colorize(color: Color.Value, content: SwiftTUIContentType) -> SwiftTUIContentType {
        return ColorDecorate.start + "\(color)" + "m" + content + ColorDecorate.end
    }
    static dynamic internal func colorize(color: Color.Value, content: SwiftTUIContentType) -> SwiftTUIContentType {
        _colorize(color: color, content: content)
    }
    
}
