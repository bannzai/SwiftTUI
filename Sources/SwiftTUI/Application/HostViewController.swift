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
    
    internal var drawnContent: [Rune] = []
    
    internal var keepForegroundColor: Color? = nil
    internal var keepBackgroundColor: Color? = nil
}

internal protocol ContentSetter {
    func add(rune: Rune)
}
extension ContentSetter {
    func add(unicodeScalar: Unicode.Scalar) {
        add(rune: Rune(unicodeScalar))
    }
    
    func add(character: Character) {
        character.unicodeScalars.forEach(add(unicodeScalar:))
    }
    
    func add(string: String) {
        string.forEach(add(character:))
    }
}

internal protocol AttributeSetter {
    func setForegroundColor(_ color: Color)
    func setBackgroundColor(_ color: Color)
}

internal protocol AttributeRestorer {
    var keepForegroundColor: Color? { get nonmutating set }
    var keepBackgroundColor: Color? { get nonmutating set }
    
    func restoreForegroundColor()
    func restoreBackgroundColor()
}

extension AttributeRestorer where Self: AttributeSetter {
    func restoreForegroundColor() {
        setForegroundColor(Style.Color.foreground.color)
        keepForegroundColor = nil
    }
    func restoreBackgroundColor() {
        setBackgroundColor(Style.Color.background.color)
        keepBackgroundColor = nil
    }
}

internal protocol DrawableDriver: class, ContentSetter, AttributeSetter, AttributeRestorer {
    
}

fileprivate let pairNumber: Int16 = 1

// MARK: - Draw on console
extension HostViewController: Drawable, DrawableDriver {
    func add(rune: Rune) {
        let point = drawPoint()
        
        cncurses.addch(rune)
        drawnContent.append(rune)

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
    
    func setForegroundColor(_ color: Color) {
        keepForegroundColor = color
        let backgroundColor = keepBackgroundColor ?? Style.Color.background.color
        init_pair(pairNumber, color.foregroundColor, backgroundColor.backgroundColor)
    }
    
    func setBackgroundColor(_ color: Color) {
        keepBackgroundColor = color
        let foregroundColor = keepForegroundColor ?? Style.Color.foreground.color
        init_pair(pairNumber, foregroundColor.foregroundColor, color.backgroundColor)
    }
    
    private func resetContent() {
        drawnContent = []
    }
    
    func draw() {
        resetContent()
        let visitor = ViewContentVisitor(driver: self)
        visitor.visit(root)
        debugLogger.debug(userInfo: drawnContent)
    }
}
