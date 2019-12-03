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
    var flag: Bool = false
    public init(root: Root) {
        self.root = root
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (_) in
            self?.draw()
        }
    }
}

extension HostViewController: Drawable {
    func draw() {
        flag = !flag
        let visitor = ViewVisitor()
        var result = visitor.visit(root)
        result = flag ? Terminal.colorize(color: Color.cyan.backgroundColor, content: result) : result
        let size = windowSize()
        var content = ""
        for h in stride(from: 0, to: size.height!, by: 1) {
            for w in stride(from: 0, to: size.width!, by: 1) {
                content += "\((w + 1) + (h * size.width!))"
            }
            content += "\n"
        }
        Terminal.File.output.write(content.data(using: .utf8)!)
    }
    
    func windowSize() -> Size {
//        let a = String(utf8String: Darwin.getenv("$COLUMNS"))!
//        let columns = PhysicalDistance(a)!
//        let lines = PhysicalDistance(String(utf8String: Darwin.getenv("LINES"))!)!
        return Size(width: 273, height: 31)
    }
}
