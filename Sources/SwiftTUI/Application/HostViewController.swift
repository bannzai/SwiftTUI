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
        debugLogger.debug(userInfo: "start add string: \(string)")
        string.forEach(add(character:))
        debugLogger.debug(userInfo: "end add string: \(string)")
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

fileprivate var pairNumber: Int32 = 2

// MARK: - Draw on console
extension HostViewController: Drawable, DrawableDriver {
    func add(rune: Rune) {
        debugLogger.debug(userInfo: "start rune: \(rune)")

        cncurses.addch(rune)
        drawnContent.append(rune)

        let point = drawPoint()
        debugLogger.debug(userInfo: "point is \(point)")
        debugLogger.debug(userInfo: "window size is \(window.frame.size)")
        switch point.x < window.frame.size.width {
        case true:
            sharedCursor.moveTo(x: point.x + 1, y: point.y)
        case false:
            sharedCursor.moveTo(x: 0, y: point.y + 1)
        }
        debugLogger.debug(userInfo: "end rune: \(rune)")
    }
    
    func setBackgroundColor(_ color: Color) {
        keepBackgroundColor = color
        let foregroundColor = keepForegroundColor ?? Style.Color.foreground.color
        init_pair(Int16(pairNumber), foregroundColor.value, color.value)
        attrset(COLOR_PAIR(pairNumber))
        pairNumber += 1
    }
    
    func setForegroundColor(_ color: Color) {
        keepForegroundColor = color
        let backgroundColor = keepBackgroundColor ?? Style.Color.background.color
        let result = init_pair(Int16(pairNumber), color.value, backgroundColor.value)
        debugLogger.debug(userInfo: "color: \(color), result: \(result)")
        attrset(COLOR_PAIR(pairNumber))
        pairNumber += 1
    }
    
    private func resetContent() {
        drawnContent = []
    }
    
    func draw() {
        resetContent()
        
        let graphVisitor = ViewGraphSetVisitor()
        let graph = graphVisitor.visit(root)

        let sizeVisitor = ViewSetRectVisitor()
        _ = sizeVisitor.visit(graph)
        
        configureView: do {
            let visitor = ViewContentVisitor(driver: self)
            visitor.visit(graph)
            debugLogger.debug(userInfo: drawnContent)
        }
        cncurses.refresh()
    }
}
