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
    public init(root: Root) {
        self.root = root
    }

    internal weak var window: Window?
}

extension HostViewController: Drawable {
    func draw() {
        let visitor = ViewVisitor()
        let result = visitor.visit(root)
        debugLogger.debug(userInfo: result)
    }
}
