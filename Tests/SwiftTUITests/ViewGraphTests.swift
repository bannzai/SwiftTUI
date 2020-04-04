//
//  ViewGraphTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/25.
//

import XCTest
@testable import SwiftTUI

class ViewGraphTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    func testPositionToWindow() {
        XCTContext.runActivity(named: "simply tests") { _ in
            let parentGraph = ViewGraphImpl(view: EmptyView())
            parentGraph.rect.origin.x = 10
            parentGraph.rect.origin.y = 15
            
            let graph = ViewGraphImpl(view: EmptyView())
            graph.rect.origin.x = 10
            graph.rect.origin.y = 15
            
            parentGraph.addChild(graph)
            
            XCTAssertEqual(graph.positionToWindow(), Point(x: 20, y: 30))
        }
        XCTContext.runActivity(named: "when Text.border()") { _ in
            let view = Text("123").border()
            let graph = ViewGraphSetVisitor().visit(view)
            graph.accept(visitor: .init())
            
            let childGraph = graph.children[0]
            XCTAssertTrue(childGraph.anyView is Text)

            XCTAssertEqual(childGraph.positionToWindow(), Point(x: 1, y: 1))
        }
    }
}
