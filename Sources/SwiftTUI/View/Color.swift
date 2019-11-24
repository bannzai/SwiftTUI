//
//  Color.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

/// An environment-dependent color.
///
/// A `Color` is a late-binding token - its actual value is only resolved
/// when it is about to be used in a given environment. At that time it is
/// resolved to a concrete value.
public enum Color: Hashable {
    case `default`
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case lightGray
    case darkGray
    case lightRed
    case lightGreen
    case lightYellow
    case lightBlue
    case lightMagenta
    case lightCyan
    case white
    
    typealias Value = Int
    
    var foregroundColor: Value {
        switch self {
        case .default: return 39
        case .black: return 30
        case .red: return 31
        case .green: return 32
        case .yellow: return 33
        case .blue: return 34
        case .magenta: return 35
        case .cyan: return 36
        case .lightGray: return 37
        case .darkGray: return 90
        case .lightRed: return 91
        case .lightGreen: return 92
        case .lightYellow: return 93
        case .lightBlue: return 94
        case .lightMagenta: return 95
        case .lightCyan: return 96
        case .white: return 97
        }
    }
    
    var backgroundColor: Value {
        switch self {
        case .default: return 49
        case .black: return 40
        case .red: return 41
        case .green: return 42
        case .yellow: return 43
        case .blue: return 44
        case .magenta: return 45
        case .cyan: return 46
        case .lightGray: return 47
        case .darkGray: return 100
        case .lightRed: return 101
        case .lightGreen: return 102
        case .lightYellow: return 103
        case .lightBlue: return 104
        case .lightMagenta: return 105
        case .lightCyan: return 106
        case .white: return 107
        }
    }
}

extension Color: View {
    public var _baseProperty: _ViewBaseProperties? {
        return nil
    }
    public typealias Body = Never
    public func _typeOf() -> _AcceptableType {
        .single(.color)
    }
}

extension Color: Acceptable {
    public func accept<V>(visitor: V) -> AnyViewVisitor.VisitResult where V : AnyViewVisitor {
        SwiftTUIContentType()
    }
    public func accept<V>(visitor: V) -> AnyListViewVisitor.VisitResult where V : AnyListViewVisitor {
        []
    }
}

public enum Style {
    public enum Color {
        case background
        case text
        
        var color: SwiftTUI.Color {
            switch self {
            case .background:
                return .default
            case .text:
                return .white
            }
        }
    }
}
