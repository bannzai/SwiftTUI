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
        XCTContext.runActivity(named: "when call border(.blue)") { (_) in
            let view = Text("123").border(.blue)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width + defaultBorderWidth * 2, height: "123".height + defaultBorderWidth * 2))
        }
    }
    
    func testChildrenPosition() throws {
        func prepare<T: View>(view: T) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            return graph
        }
        XCTContext.runActivity(named: "when call border(.blue)") { (_) in
            let view = Text("123").border(.blue)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            
            XCTAssertEqual(textGraph.rect.origin, Point(x: defaultBorderWidth, y: defaultBorderWidth))
        }
        XCTContext.runActivity(named: "when layout specify vector via border(color: .blue, edges: .leading)") { (_) in
            let view = Text("123").border(.blue, .leading)

            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)

            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)

            XCTAssertEqual(textGraph.rect.origin, Point(x: 1, y: 0))
        }
        XCTContext.runActivity(named: "when border via border(color: .blue).border(color: .red)") { (_) in
            let view = Text("123").border(.blue).border(.red)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)

            let blueBorderGraph = graph.children[0]
            XCTAssertTrue(blueBorderGraph.anyView is ModifiedContent<Text, _BorderModifier>)
            XCTAssertEqual(blueBorderGraph.rect.origin, Point(x: 1, y: 1))
            
            let textGraph = blueBorderGraph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.origin, Point(x: 1, y: 1))
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
        XCTContext.runActivity(named: "when call border(.blue)") { (_) in
            let view = Text("123").border(.blue)
            
            let graph = prepare(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            
            let content = driver.content()
            
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertTrue(content.contains(Edge.Set.leadingTop.defaultDelimiter))
            XCTAssertTrue(content.contains(Edge.Set.trailingTop.defaultDelimiter))
            XCTAssertTrue(content.contains(Edge.Set.leadingBottom.defaultDelimiter))
            XCTAssertTrue(content.contains(Edge.Set.trailingBottom.defaultDelimiter))
            XCTAssertTrue(content.contains(Edge.Set.vertical.defaultDelimiter))
            XCTAssertTrue(content.contains(Edge.Set.horizontal.defaultDelimiter))
            XCTAssertTrue(content.contains("123"))
        }
    }
}
