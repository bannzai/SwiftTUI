//
//  Terminal.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/17.
//

import Foundation
import Darwin

internal struct Terminal { }
    
// MARK: - Decorate Color
extension Terminal {
    struct ColorDecorate {
        static internal let escapeSequence = "\u{001B}" // NOTE: \e
        static internal let start = "\(escapeSequence)["
        static internal let end = "\(escapeSequence)[0m"
    }
    
    // See: https://misc.flogisoft.com/bash/tip_colors_and_formatting
    static internal func _colorize(color: Color.Value, content: SwiftTUIContentType) -> SwiftTUIContentType {
        return ColorDecorate.start + "\(color)" + "m" + content + ColorDecorate.end
    }
    static dynamic internal func colorize(color: Color.Value, content: SwiftTUIContentType) -> SwiftTUIContentType {
        _colorize(color: color, content: content)
    }
}

// MARK: - IO
extension Terminal {
    struct File {
        // FIXME: Run on Xcode
        static let input: FileHandle = {
            switch Debug.EnvironmentVariables.isRunOnXcode {
            case false:
                let fileDescriptor = Darwin.open("/dev/tty", Darwin.O_RDONLY)
                let handler = FileHandle(fileDescriptor: fileDescriptor)
                return handler
            case true:
                return FileHandle.standardInput
            }
        }()
        static let output: FileHandle = {
            switch Debug.EnvironmentVariables.isRunOnXcode {
            case false:
                let fileDescriptor = Darwin.open("/dev/tty", Darwin.O_WRONLY)
                let handler = FileHandle(fileDescriptor: fileDescriptor)
                return handler
            case true:
                return FileHandle.standardOutput
            }
        }()
    }
}
