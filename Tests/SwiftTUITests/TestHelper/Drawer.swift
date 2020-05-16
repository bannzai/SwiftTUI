//
//  Drawer.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/11.
//

import XCTest
@testable import SwiftTUI

final class TestDrawer: Drawable {
    var _draw: () -> Void
    init(draw: @escaping () -> Void) {
        self._draw = draw
    }
    func draw() {
        _draw()
    }
}
