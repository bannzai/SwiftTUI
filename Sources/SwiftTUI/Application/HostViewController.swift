//
//  HostViewController.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/03.
//

import Foundation

internal protocol Drawable: class {
    func draw()
}

public final class HostViewController<Root: View> {
    internal let root: Root
    
    internal weak var window: Window?

    public init(root: Root) {
        self.root = root
    }
}

extension HostViewController: Drawable {
    func draw() {
        let visitor = ViewVisitor()
        let result = visitor.visit(root)
        debugLogger.debug(userInfo: result)
    }
    
    func windowSize() -> Size {
//        let a = String(utf8String: Darwin.getenv("$COLUMNS"))!
//        let columns = PhysicalDistance(a)!
//        let lines = PhysicalDistance(String(utf8String: Darwin.getenv("LINES"))!)!
        return Size(width: 273, height: 31)
    }
}
