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
        XCTContext.runActivity(named: "when call border(.blue)") { (_) in
            let view = Text("123").border(.blue)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width + defaultBorderWidth * 2, height: "123".height + defaultBorderWidth * 2))
        }
        XCTContext.runActivity(named: "border(.blue).border(.red)") { (_) in
            let view = Text("123").border(.blue).border(.red)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width + (defaultBorderWidth * 2) * 2, height: "123".height + (defaultBorderWidth * 2) * 2))
        }
    }
    
    func testChildrenPosition() throws {
        XCTContext.runActivity(named: "when call border(.blue)") { (_) in
            let view = Text("123").border(.blue)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            
            XCTAssertEqual(textGraph.rect.origin, Point(x: defaultBorderWidth, y: defaultBorderWidth))
        }
        XCTContext.runActivity(named: "when layout specify vector with[ border(color: .blue, edges: .leading)") { (_) in
            let view = Text("123").border(.blue, .leading)

            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)

            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)

            XCTAssertEqual(textGraph.rect.origin, Point(x: 1, y: 0))
        }
        XCTContext.runActivity(named: "when border(color: .blue).border(color: .red)") { (_) in
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
        XCTContext.runActivity(named: "when call border(.blue)") { (_) in
            let view = Text("123").border(.blue)
            
            let graph = prepare(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            let content = driver.content()
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            assert(Edge.Set.leadingTop.defaultDelimiter == Edge.Set.trailingTop.defaultDelimiter && Edge.Set.trailingTop.defaultDelimiter == Edge.Set.trailingBottom.defaultDelimiter && Edge.Set.trailingBottom.defaultDelimiter == Edge.Set.leadingBottom.defaultDelimiter, "this test case need the same corner defaultDelimiter")
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter
            
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), 1 * 4)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), 1 * 2)
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), 3 * 2)
            XCTAssertTrue(content.contains("123"))
        }
        XCTContext.runActivity(named: "when call border(.blue).border(.red)") { (_) in
            let view = Text("123").border(.blue).border(.red)
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            
            let content = driver.content()
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            assert(Edge.Set.leadingTop.defaultDelimiter == Edge.Set.trailingTop.defaultDelimiter && Edge.Set.trailingTop.defaultDelimiter == Edge.Set.trailingBottom.defaultDelimiter && Edge.Set.trailingBottom.defaultDelimiter == Edge.Set.leadingBottom.defaultDelimiter, "this test case need the same corner defaultDelimiter")
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter

            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertTrue(driver.storedForegroundColors.contains(.red))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), 1 * 4 * 2)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), 1 * 2 + 3 * 2)
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), 3 * 2 + 5 * 2)
            XCTAssertTrue(content.contains("123"))
        }
        XCTContext.runActivity(named: "when call border(.blue).border(.red) and contained for VStack") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                Text(",")
                    .border(.red)
                    .border(.blue)
                Text("World")
            }

            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            
            let content = driver.content()
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            assert(Edge.Set.leadingTop.defaultDelimiter == Edge.Set.trailingTop.defaultDelimiter && Edge.Set.trailingTop.defaultDelimiter == Edge.Set.trailingBottom.defaultDelimiter && Edge.Set.trailingBottom.defaultDelimiter == Edge.Set.leadingBottom.defaultDelimiter, "this test case need the same corner defaultDelimiter")
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter
            
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertTrue(driver.storedForegroundColors.contains(.red))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), 1 * 4 * 2)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), 1 * 2 + 3 * 2)
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), 1 * 2 + 3 * 2)
            XCTAssertTrue(content.contains("Hello"))
            XCTAssertTrue(content.contains(","))
            XCTAssertTrue(content.contains("World"))
        }
    }
}
