//
//  KeyType.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/06.
//

import Foundation
import cncurses

public typealias KeyTypeOffset = Int32
public protocol CtrlKeyPairType {
    static func ctrl(value: KeyTypeOffset) -> Self?
}

public enum KeyType {
    case space
    case esc
    case alphameric(Alphameric)
    case numeric(Numeric)
    case ctrl(CtrlKeyPairType)
    case function(Function)
    case direction(Direction)
    
    // NOTE: e.g) M-E, M-A ...
    // FIXME: Alter key unsupported. Because it is very complex key pair...
    // I will adapt alter key pattern later.
    // case alt(AlterKeyPairType)

    public init(keyname: UnsafePointer<CChar>) {
        switch keyname.pointee {
        case 0:
            self = .space
            return
        case 27:
            self = .esc
            return
        case _:
            break
        }
        
        let specialKey = String.init(cString: keyname)
        
        // NOTE: e.g) ^I,^A ...
        if specialKey.hasPrefix("^") {
            switch (Alphameric.ctrl(value: KeyTypeOffset(keyname.pointee)), Numeric.ctrl(value: KeyTypeOffset(keyname.pointee))) {
            case (let alphameric?, nil):
                self = .ctrl(alphameric)
                return
            case (nil, let numeric?):
                self = .ctrl(numeric)
                return
            case (nil, nil), (_?, _?):
                assertionFailure("unexpected pattern for control key \(specialKey) and value of \(keyname.pointee)")
                break
            }
        }
        
        if let functionKey = Function(rawValue: keyname.pointee) {
            self = .function(functionKey)
            return
        }
        
        if let direction = Direction(rawValue: keyname.pointee) {
            self = .direction(direction)
            return
        }
        
        if let alphameric = Alphameric(rawValue: keyname.pointee) {
            self = .alphameric(alphameric)
            return
        }

        fatalError("unexpected KeyType of \(keyname.pointee), special key value for \(specialKey)")
    }
}

// MARK: - Direction
extension KeyType {
    public enum Direction: Int8, CaseIterable {
        case down
        case up
        case left
        case right
        
        public init?(rawValue: Int8) {
            guard let direction = Direction.allCases.enumerated().first(where: { rawValue == KEY_LEFT + KeyTypeOffset($0.offset) })?.element else {
                return nil
            }
            self = direction
        }
    }
}

// MARK: - Function
extension KeyType {
    public enum Function: Int8, CaseIterable {
        case F1
        case F2
        case F3
        case F4
        case F5
        case F6
        case F7
        case F8
        case F9
        case F10
        case F11
        case F12
        
        public init?(rawValue: Int8) {
            guard let value = Function.allCases.enumerated().first(where: { rawValue == cncurses.KEY_F0 + KeyTypeOffset($0.offset) })?.element else {
                return nil
            }
            self = value
        }
    }
}

// MARK: - Numeric
extension KeyType {
    public enum Numeric: Int8, CtrlKeyPairType, CaseIterable {
        case zero = 48
        case one
        case two
        case three
        case four
        case five
        case six
        case seven
        case eight
        case nine
        
        private static let ctrlNumericStart: KeyTypeOffset = 0
        public static func ctrl(value: KeyTypeOffset) -> KeyType.Numeric? {
            Numeric.allCases.enumerated().first { KeyTypeOffset($0.offset) + ctrlNumericStart == value }?.element
        }
    }
}

// MARK: - Alphameric
extension KeyType {
    public enum Alphameric: Int8, CtrlKeyPairType, CaseIterable {
        case a = 97
        case b
        case c
        case d
        case e
        case f
        case g
        case h
        case i
        case j
        case k
        case l
        case m
        case n
        case o
        case p
        case q
        case r
        case s
        case t
        case u
        case v
        case w
        case x
        case y
        case z
        case A = 65
        case B
        case C
        case D
        case E
        case F
        case G
        case H
        case I
        case J
        case K
        case L
        case M
        case N
        case O
        case P
        case Q
        case R
        case S
        case T
        case U
        case V
        case W
        case X
        case Y
        case Z
        
        internal static var smallAlphabets: [Alphameric] {
            Alphameric.allCases.filter { $0.isSmall }
        }
        private static let ctrlSmallAlphabetStart: KeyTypeOffset = 0
        public static func ctrl(value: KeyTypeOffset) -> Alphameric? {
            smallAlphabets.enumerated().first { KeyTypeOffset($0.offset) + ctrlSmallAlphabetStart == value }?.element
        }
        
        public var isSmall: Bool {
            rawValue > Alphameric.a.rawValue
        }
        
        public var isLarge: Bool {
            !isSmall
        }
        
        public var alphabet: String {
            return "\(self)"
        }
    }
}
