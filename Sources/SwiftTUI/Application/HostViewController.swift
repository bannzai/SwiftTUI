//
//  HostViewController.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/03.
//

import Foundation

public typealias Rune = UInt32
internal protocol Drawable: class {
    func draw()
}

public final class HostViewController<Root: View> {
    internal let root: Root
    public init(root: Root) {
        self.root = root
    }

    internal weak var window: Window?
}

// MARK: - Draw on console
extension HostViewController: Drawable {
    func set(rune: Rune, column: PhysicalDistance, row: PhysicalDistance) {
        
    }
    
    func add(rune: Rune) {
        
    }
    
    func add(unicodeScalar: Unicode.Scalar) {
        add(rune: Rune(unicodeScalar))
    }
    
    func add(character: Character) {
        character.unicodeScalars.forEach(add(unicodeScalar:))
    }
    
    func add(string: String) {
        string.forEach(add(character:))
    }
    
    func draw() {
        let visitor = ViewVisitor()
        let result = visitor.visit(root)
        debugLogger.debug(userInfo: result)
    }
}
