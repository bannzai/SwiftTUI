//
//  KeyType.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/06.
//

import Foundation
import cncurses

public protocol AltKeyPairType {}
public protocol CtrlKeyPairType {}

public enum KeyType {
    case space
    case alphameric(Alphameric)
    case numeric(Numeric)
    case alt(AltKeyPairType)
    case ctrl(CtrlKeyPairType)
    case function(Function)

    public init(keyname: UnsafePointer<CChar>) {
        switch keyname.pointee {
        case 0:
            self = .space
            return
        case _:
            break
        }
        
        let specialKey = String.init(cString: keyname)
        
        // NOTE: e.g) M-E, M-A ...
        if specialKey.hasPrefix("M-") {
            switch (Alphameric(rawValue: keyname.pointee), Numeric(rawValue: keyname.pointee)) {
            case (let alphameric?, nil):
                self = .alt(alphameric)
                return
            case (nil, let numeric?):
                self = .alt(numeric)
                return
            case (nil, nil), (_?, _?):
                assertionFailure("unexpected pattern for special key \(specialKey) and value of \(keyname.pointee)")
                break
            }
        }
        
        // NOTE: e.g) ^I,^A ...
        if specialKey.hasPrefix("^") {
            switch (Alphameric(rawValue: keyname.pointee), Numeric(rawValue: keyname.pointee)) {
            case (let alphameric?, nil):
                self = .ctrl(alphameric)
                return
            case (nil, let numeric?):
                self = .ctrl(numeric)
                return
            case (nil, nil), (_?, _?):
                assertionFailure("unexpected pattern for special key \(specialKey) and value of \(keyname.pointee)")
                break
            }
        }
        
        if let functionKey = Function.init(rawValue: keyname.pointee) {
            self = .function(functionKey)
            return
        }

        fatalError("unexpected KeyType of \(keyname.pointee), special key value for \(specialKey)")
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
            guard let value = Function.allCases.enumerated().first(where: { rawValue == cncurses.KEY_F0 + Int32($0.offset) })?.element else {
                return nil
            }
            self = value
        }
    }
}

// MARK: - Numeric
extension KeyType {
    public enum Numeric: Int8, CaseIterable, AltKeyPairType, CtrlKeyPairType {
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
    }
}

// MARK: - Alphameric
extension KeyType {
    public enum Alphameric: Int8, CaseIterable, AltKeyPairType, CtrlKeyPairType {
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
    }
}
