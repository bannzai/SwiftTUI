//
//  KeyEvent.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/07.
//

import Foundation

public struct KeyEvent {
    internal let keyType: KeyType
    
    public init(keyType: KeyType) {
        self.keyType = keyType
    }
}

public extension KeyEvent {
    var isControl: Bool {
        switch keyType {
        case .ctrl:
            return true
        case _:
            return false
        }
    }
}
