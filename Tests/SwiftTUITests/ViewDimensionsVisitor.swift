//
//  ViewAlignmentVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/10.
//

import XCTest
@testable import SwiftTUI

class ViewDimensionsVisitorTests: XCTestCase {
    struct CustomView<Target: View>: View {
        let body: Target
    }
    class DummyScreen: Screen {
        override var columns: PhysicalDistance { 100 }
        override var rows: PhysicalDistance { 100 }
    }
    
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }

    func testVisit() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            
            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(graph)

            XCTAssertEqual(dimensions.width, "hoge".width)
            XCTAssertEqual(dimensions.height, 1)
            XCTAssertEqual(dimensions[HorizontalAlignment.default], "hoge".width / 2)
            XCTAssertEqual(dimensions[VerticalAlignment.default], 0)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(dimensions[explicit: VerticalAlignment.default])
        }
        
        XCTContext.runActivity(named: "when Text with content with linebreak") { (_) in
            let view = Text("hoge\nfuga")

            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            
            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(graph)
            
            XCTAssertEqual(dimensions.width, "hoge".width)
            XCTAssertEqual(dimensions.height, 2)
            XCTAssertEqual(dimensions[HorizontalAlignment.default], "hoge".width / 2)
            XCTAssertEqual(dimensions[VerticalAlignment.default], 1)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(dimensions[explicit: VerticalAlignment.default])
        }
    }

}
