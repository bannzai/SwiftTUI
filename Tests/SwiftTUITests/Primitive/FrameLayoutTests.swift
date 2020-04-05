//
//  FrameLayoutTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/01.
//

import XCTest
@testable import SwiftTUI

class FrameLayoutTests: XCTestCase {
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
        XCTContext.runActivity(named: "when call frame()") { (_) in
            let view = Text("123").frame()
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            XCTAssertEqual(graph.rect.size, Size(width: "123".width, height: "123".height))

            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.size, graph.rect.size)
        }
        XCTContext.runActivity(named: "when frame with `width` and `width` > textGraph.rect.size.width") { (_) in
            let view = Text("123").frame(width: 10)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            XCTAssertEqual(graph.rect.size, Size(width: 10, height: "123".height))
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.size, Size(width: "123".width, height: "123".height))
        }
        XCTContext.runActivity(named: "when frame with `height` and `height` > textGraph.rect.size.height") { (_) in
            let view = Text("123").frame(height: 10)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            XCTAssertEqual(graph.rect.size, Size(width: "123".width, height: 10))

            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.size, Size(width: "123".width, height: "123".height))
        }
        XCTContext.runActivity(named: "when frame with `width` and `width` < textGraph.rect.size.width") { (_) in
            let width = PhysicalDistance(1)
            let view = Text("123").frame(width: width)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            XCTAssertEqual(graph.rect.size, Size(width: width, height: "123".width))
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.size, Size(width: width, height: "123".width / width))
        }
        XCTContext.runActivity(named: "when call frame(width:height:).frame(width:height:)") { (_) in
            let view = Text("123").frame(width: 10, height: 10).frame(width: 20, height: 20)
            
            let frameGraph20 = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            frameGraph20.accept(visitor: visitor)
            XCTAssertEqual(frameGraph20.rect.size, Size(width: 20, height: 20))

            let frameGraph10 = frameGraph20.children[0]
            XCTAssertTrue(frameGraph10.anyView is ModifiedContent<Text, _FrameLayout>)
            XCTAssertEqual(frameGraph10.rect.size, Size(width: 10, height: 10))
        }
    }
    
    func testChildrenPosition() throws {
        func prepare<T: View>(view: T) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            return graph
        }
        XCTContext.runActivity(named: "when call frame()") { (_) in
            let view = Text("123").frame()
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            
            XCTAssertEqual(textGraph.rect.origin, .zero)
        }
        XCTContext.runActivity(named: "when frame() with width and height and alignment is center") { (_) in
            let view = Text("1234").frame(width: 10, height: 3)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.origin, Point(x: 3, y: 1))
        }
        XCTContext.runActivity(named: "when frame() with width and height and alignment is leading") { (_) in
            let view = Text("1234").frame(width: 10, height: 3, alignment: .leading)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.origin, Point(x: 0, y: 1))
        }
        XCTContext.runActivity(named: "when frame() with width and height and alignment is trailing") { (_) in
            let view = Text("1234").frame(width: 10, height: 3, alignment: .trailing)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.origin, Point(x: 6, y: 1))
        }
    }
    
    func testContent() {
        XCTContext.runActivity(named: "when call frame") { (_) in
            let view = Text("123").frame()
            
            let graph = prepareSizedGraph(view: view)
            let visitor = ViewContentVisitor(driver: Driver())
            graph.accept(visitor: visitor)
            
            // Keep test for check not call fatalError
        }
        
        XCTContext.runActivity(named: "check about divide of zero pattern") { (_) in
            let view = Text("123").padding(2).frame(width: 4, height: 3)
            
            let graph = prepareSizedGraph(view: view)
            let visitor = ViewContentVisitor(driver: Driver())
            graph.accept(visitor: visitor)
            
            // Keep test for check divide of zero
        }
    }
    
    func testContentForIllegalCase() {
        func prepare<T: View>(view: T) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            let setRectVisitor = ViewSetRectVisitor()
            graph.accept(visitor: setRectVisitor)
            return graph
        }
        XCTContext.runActivity(named: "for illegal pattern about to proposedSize is zero") { (_) in
            let view = Text("123").frame(width: 0, height: 0)
            
            let graph = prepare(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            
            let content = driver.content()
            
            XCTAssertFalse(content.contains("123"))
        }
    }
}
