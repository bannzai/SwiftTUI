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
}

extension HostViewController: Drawable {
    func draw() {
        let visitor = ViewVisitor()
        let result = visitor.visit(root)
        Terminal.File.output.write(result.data(using: .utf8)!)
    }
}
