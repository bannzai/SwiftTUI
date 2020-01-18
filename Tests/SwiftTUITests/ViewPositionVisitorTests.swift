//
//  ViewOriginVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/18.
//

import XCTest
@testable import SwiftTUI

class ViewPositionVisitorTests: XCTestCase {
    class DummyScreen: Screen {
        override var columns: PhysicalDistance { 100 }
        override var rows: PhysicalDistance { 100 }
    }
    
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    private func prepare<T: View>(view: T, viewListOption: ViewVisitorListOption = .vertical) -> ViewGraph {
        let graphVisitor = ViewGraphSetVisitor()
        let graph = graphVisitor.visit(view: view)
        graph.listType = viewListOption
        
        // FIXME: Remove Size Visitor??
        let sizeVisitor = ViewSizeVisitor()
        _ = sizeVisitor.visit(graph)
        
        let dimensionsVisitor = ViewDimensionsVisitor()
        _ = dimensionsVisitor.visit(graph)
        
        return graph
    }
    
    func testExtract() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            XCTAssertEqual(position.x, "hoge".width / 2)
            XCTAssertEqual(position.y, 0)
        }
        XCTContext.runActivity(named: "when Text with content with linebreak") { (_) in
            let view = Text("hoge\nfuga")
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            XCTAssertEqual(position.x, "hoge".width / 2)
            XCTAssertEqual(position.y, 1)
        }
        XCTContext.runActivity(named: "when TupleView<Text, Text, Text>") { (_) in
            let view = TupleView((
                Text("1"),
                Text("23"),
                Text("456")
            ))
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            let height = elementCount + spacing
            XCTAssertEqual(position.x, "456".width / 2)
            XCTAssertEqual(position.y, height / 2)
        }
    }
    
    func test() {
    }
    
    func testAccept() {
        
    }
}
