//
//  HostViewController.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/03.
//

import Foundation
import cncurses

public typealias Rune = UInt32
internal protocol Drawable: class {
    func draw()
}

public final class HostViewController<Root: View> {
    internal let root: Root
    public init(root: Root) {
        self.root = root
    }

    internal weak var window: Window!
}

// MARK: - Draw on console
extension HostViewController: Drawable {
    func add(rune: Rune) {
        let point = drawPoint()
        
        cncurses.addch(rune)

        switch point.x >= window.frame.size.width {
        case false:
            sharedCursor.moveTo(x: point.x + 1, y: point.y)
        case true:
            break
        }
        switch point.y >= window.frame.size.height {
        case false:
            sharedCursor.moveTo(x: 0, y: point.y + 1)
        case true:
            sharedCursor.moveTo(x: 0, y: 0)
        }
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
        let visitor = ViewContentVisitor()
        let result = visitor.visit(root)
        debugLogger.debug(userInfo: result)
    }
}
