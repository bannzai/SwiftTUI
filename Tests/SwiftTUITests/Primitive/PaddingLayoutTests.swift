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
        func prepare<T: View>(view: T) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            return graph
        }
        XCTContext.runActivity(named: "when call padding()") { (_) in
            let view = Text("123").padding()

            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)

            XCTAssertEqual(graph.rect.size, Size(width: "123".width + defaultPadding * 2, height: "123".height + defaultPadding * 2))
        }
        XCTContext.runActivity(named: "when padding layout specify vector and length via .padding(.leading, 10)") { (_) in
            let view = Text("123").padding(.leading, 10)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width + 10, height: "123".height))
        }
        XCTContext.runActivity(named: "when padding layout specify vector and length via .padding(.all, 10)") { (_) in
            let view = Text("123").padding(.all, 10)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width + 20, height: "123".height + 20))
        }
    }
    
    
    func testChildrenPosition() throws {
        func prepare<T: View>(view: T) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            return graph
        }
        XCTContext.runActivity(named: "when call padding()") { (_) in
            let view = Text("123").padding()
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            
            XCTAssertEqual(textGraph.rect.origin, Point(x: defaultPadding, y: defaultPadding))
        }
        XCTContext.runActivity(named: "when padding layout specify vector and length via .padding(.leading, 10)") { (_) in
            let view = Text("123").padding(.leading, 10)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)

            XCTAssertEqual(textGraph.rect.origin, Point(x: 10, y: 0))
        }
        XCTContext.runActivity(named: "when padding layout specify vector and length via .padding(.all, 10)") { (_) in
            let view = Text("123").padding(.all, 10)
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            
            XCTAssertEqual(textGraph.rect.origin, Point(x: 10, y: 10))
        }
    }
}
