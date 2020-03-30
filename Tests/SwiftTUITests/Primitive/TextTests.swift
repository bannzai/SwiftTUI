//
//  TextTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/30.
//

import XCTest
@testable import SwiftTUI

class TextTests: XCTestCase {
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
        XCTContext.runActivity(named: "when Text contains text") { (_) in
            let view = Text("text")
            
            let graph = prepare(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "text".width, height: 1))
        }
        XCTContext.runActivity(named: "when Text with content with linebreak code") { (_) in
            let view = Text("text\ntext")
            
            let graph = prepare(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)

            XCTAssertEqual(graph.rect.size, Size(width: "text".width, height: 2))
        }
    }

    
    func testPosition() {
        func prepare<T: View>(view: T) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            return graph
        }
        XCTContext.runActivity(named: "when Text has content") { (_) in
            let view = Text("hoge")
            let graph = prepare(view: view)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
        }
    }

}
