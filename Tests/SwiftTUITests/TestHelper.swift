//
//  TestHelper.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation
import XCTest
@testable import SwiftTUI

struct DebuggerView: View, ViewContentAcceptable {
    let closure: () -> Void
    
    var body: some View {
        EmptyView()
    }
    
    func accept<V>(visitor: V) -> ViewContentVisitor.VisitResult where V : ViewContentVisitor {
        closure()
        return visitor.visit(body)
    }
}


class TestCursor: Cursor {
    internal var x: PhysicalDistance = 0 {
        didSet { xHistory.append(x) }
    }
    internal var y: PhysicalDistance = 0 {
        didSet { yHistory.append(y) }
    }
    var xHistory: [PhysicalDistance] = []
    var yHistory: [PhysicalDistance] = []
    
    func moveTo(point: Point) {
        self.x = point.x
        self.y = point.y
    }
    
    func moveTo(x: PhysicalDistance, y: PhysicalDistance) {
        self.x = x
        self.y = y
    }
    
    func move(x: PhysicalDistance, y: PhysicalDistance) {
        let _x = self.x + x
        let _y = self.y + y
        self.x = _x
        self.y = _y
    }
    
    func reset() {
        moveTo(x: 0, y: 0)
        xHistory.removeAll()
        yHistory.removeAll()
    }
}

class DummyScreen: Screen {
    override var columns: PhysicalDistance { 100 }
    override var rows: PhysicalDistance { 100 }
}

final class Driver: DrawableDriver {
    var callBag: [StaticString] = []
    var storedRunes: [Rune] = []
    var storedString: String {
        storedRunes.compactMap(Unicode.Scalar.init)
            .compactMap(Character.init)
            .compactMap(String.init)
            .joined()
    }
    func add(rune: Rune) {
        callBag.append(#function)
        storedRunes.append(rune)
    }
    
    var storedForegroundColors: [Color] = []
    func setForegroundColor(_ color: Color) {
        callBag.append(#function)
        storedForegroundColors.append(color)
    }
    
    var storedBackgroundColors: [Color] = []
    func setBackgroundColor(_ color: Color) {
        callBag.append(#function)
        storedBackgroundColors.append(color)
    }
    
    var keepForegroundColor: Color?
    var keepBackgroundColor: Color?
    
    func content() -> String {
        callBag.append(#function)
        return storedRunes.compactMap(Unicode.Scalar.init)
            .map(Character.init)
            .map(String.init)
            .reduce("", +)
    }
    
}

public func XCTAssertAmbiguouseOrder<T>(_ expression1: @autoclosure () -> [T], _ expression2: @autoclosure () -> [T], _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where T : Equatable {
    func error() {
        var message = message()
        if message.isEmpty {
            message = "missing order a: \(a) between b \(b)"
        }
        XCTFail(message, file: file, line: line)
    }
    let a = expression1()
    let b = expression2()

    let large: [T]
    let small: [T]
    switch a.count > b.count {
    case true:
        large = a
        small = b
    case false:
        large = b
        small = a
    }
    
    var sCheckedOffset: Int = 0
    var lCheckedOffset: Int = 0
    for (sOffset, s) in small.enumerated() {
        if sOffset < sCheckedOffset {
            continue
        }
        sCheckedOffset = sOffset

        var exists: Bool = false
        for (lOffset, l) in large.enumerated() {
            if lOffset < lCheckedOffset {
                continue
            }
            lCheckedOffset = lOffset
            
            if s == l {
                exists = true
                break
            }
        }
        if !exists {
            error()
        }
    }
    
    if (sCheckedOffset + 1) != small.count {
        error()
    }
}

func prepareSizedGraph<T: View>(view: T, viewListOption: ViewVisitorListOption = .vertical) -> ViewGraph {
    (sharedCursor as? TestCursor)?.reset()
    
    let graphVisitor = ViewGraphSetVisitor()
    let graph = graphVisitor.visit(view)
    graph.listType = viewListOption
    
    // FIXME: Remove Size Visitor??
    let sizeVisitor = ViewSetRectVisitor()
    _ = sizeVisitor.visit(graph)
    
    return graph
}

func prepareViewGraph<T: View>(view: T) -> ViewGraph {
    let graphVisitor = ViewGraphSetVisitor()
    let graph = graphVisitor.visit(view)
    return graph
}
