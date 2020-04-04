//
//  Color.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation
import cncurses

/// An environment-dependent color.
///
/// A `Color` is a late-binding token - its actual value is only resolved
/// when it is about to be used in a given environment. At that time it is
/// resolved to a concrete value.
public enum Color: Hashable {
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
    
    typealias Value = Int16
    
    internal var value: Value {
        let cursesColorValue: Int32 = {
            switch self {
            case .black: return COLOR_BLACK
            case .red: return COLOR_RED
            case .green: return COLOR_GREEN
            case .yellow: return COLOR_YELLOW
            case .blue: return COLOR_BLUE
            case .magenta: return COLOR_MAGENTA
            case .cyan: return COLOR_CYAN
            case .white: return COLOR_WHITE
            }
        }()
        
        return Value(cursesColorValue)
    }
}

extension Color: View {
    public typealias Body = Never
}

public enum Style {
    public enum Color {
        case background
        case foreground
        case border
        case text
        
        internal var color: SwiftTUI.Color {
            switch self {
            case .background:
                return .black
            case .border:
                return .black
            case .foreground, .text:
                return .white
            }
        }
    }
}
