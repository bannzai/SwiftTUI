//
//  TestHelper.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation
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
    internal var x: PhysicalDistance = 0
    internal var y: PhysicalDistance = 0
    
    var storedMoveTo: [(x: PhysicalDistance, y: PhysicalDistance)] = []
    func moveTo(x: PhysicalDistance, y: PhysicalDistance) {
        self.x = x
        self.y = y
        storedMoveTo.append((x: x, y: y))
    }
    
    var storedMove: [(x: PhysicalDistance, y: PhysicalDistance)] = []
    func move(x: PhysicalDistance, y: PhysicalDistance) {
        let _x = self.x + x
        let _y = self.y + y
        self.x = _x
        self.y = _y
        storedMove.append((x: x, y: y))
    }
    
    func reset() {
        moveTo(x: 0, y: 0)
        storedMoveTo.removeAll()
        storedMove.removeAll()
    }
}
