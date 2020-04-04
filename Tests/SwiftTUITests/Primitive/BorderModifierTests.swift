//
//  BorderModifierTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/04.
//

import XCTest
@testable import SwiftTUI

fileprivate let defaultBorderWidth = 1
class BorderModifierTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    func testSize() throws {
        func prepare<T: View>(view: T) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            return graph
        }
        XCTContext.runActivity(named: "when call border()") { (_) in
            let view = Text("123").border()
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width + defaultBorderWidth * 2, height: "123".height + defaultBorderWidth * 2))
        }
    }
    
    
    func testContent() {
        func prepare<T: View>(view: T) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            let setRectVisitor = ViewSetRectVisitor()
            graph.accept(visitor: setRectVisitor)
            return graph
        }
        XCTContext.runActivity(named: "when call padding()") { (_) in
            let view = Text("123").border()
            
            let graph = prepare(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            
            let content = driver.content()
            
            XCTAssertTrue(content.contains(Edge.Set.leadingTop.defaultDelimiter))
        }
    }
}
