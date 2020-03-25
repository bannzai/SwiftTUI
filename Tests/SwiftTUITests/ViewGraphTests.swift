//
//  ViewGraphTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/25.
//

import XCTest
@testable import SwiftTUI

class ViewGraphTests: XCTestCase {
    func testPositionToWindow() {
        let parentGraph = ViewGraphImpl(view: EmptyView())
        parentGraph.rect.origin.x = 10
        parentGraph.rect.origin.y = 15
        
        let graph = ViewGraphImpl(view: EmptyView())
        graph.rect.origin.x = 10
        graph.rect.origin.y = 15
        
        parentGraph.addChild(graph)

        XCTAssertEqual(graph.positionToWindow(), Point(x: 20, y: 30))
    }
}
