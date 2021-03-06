//
//  PaddingLayoutTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/31.
//

import XCTest
@testable import SwiftTUI

class PaddingLayoutTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    func testSize() throws {
        XCTContext.runActivity(named: "when call padding()") { (_) in
            let view = Text("123").padding()

            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)

            XCTAssertEqual(graph.rect.size, Size(width: "123".width + defaultPadding * 2, height: "123".height + defaultPadding * 2))
        }
        XCTContext.runActivity(named: "when padding layout specify vector and length via .padding(.leading, 10)") { (_) in
            let view = Text("123").padding(.leading, 10)
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width + 10, height: "123".height))
        }
        XCTContext.runActivity(named: "when padding layout specify vector and length via .padding(.all, 10)") { (_) in
            let view = Text("123").padding(.all, 10)
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width + 20, height: "123".height + 20))
        }
        XCTContext.runActivity(named: "when call padding().padding()") { (_) in
            let view = Text("123").padding().padding()
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width + defaultPadding * 2 + defaultPadding * 2, height: "123".height + defaultPadding * 2 + defaultPadding * 2))
        }
    }
    
    func testChildrenPosition() throws {
        XCTContext.runActivity(named: "when call padding()") { (_) in
            let view = Text("123").padding()
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            
            XCTAssertEqual(textGraph.rect.origin, Point(x: defaultPadding, y: defaultPadding))
        }
        XCTContext.runActivity(named: "when padding layout specify vector and length via .padding(.leading, 10)") { (_) in
            let view = Text("123").padding(.leading, 10)
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)

            XCTAssertEqual(textGraph.rect.origin, Point(x: 10, y: 0))
        }
        XCTContext.runActivity(named: "when padding layout specify vector and length via .padding(.all, 10)") { (_) in
            let view = Text("123").padding(.all, 10)
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            
            XCTAssertEqual(textGraph.rect.origin, Point(x: 10, y: 10))
        }
        XCTContext.runActivity(named: "when call padding().padding()") { (_) in
            let view = Text("123").padding().padding()
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let paddingGraph = graph.children[0]
            XCTAssertTrue(paddingGraph.anyView is ModifiedContent<Text, _PaddingLayout>)
            XCTAssertEqual(paddingGraph.rect.origin, Point(x: defaultPadding, y: defaultPadding))

            let textGraph = paddingGraph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.origin, Point(x: defaultPadding, y: defaultPadding))
        }
    }
    
    func testContent() {
        XCTContext.runActivity(named: "when call padding()") { (_) in
            let view = Text("123").padding()
            
            let graph = prepareSizedGraph(view: view)
            let visitor = ViewContentVisitor(driver: Driver())
            graph.accept(visitor: visitor)
            
            // Keep test for check not call fatalError
        }
    }
}
