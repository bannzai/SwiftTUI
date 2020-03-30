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
    
    private func prepare<T: View>(view: T, viewListOption: ViewVisitorListOption = .vertical) -> ViewGraph {
        let graphVisitor = ViewGraphSetVisitor()
        let graph = graphVisitor.visit(view)
        graph.listType = viewListOption
        
        // FIXME: Remove Size Visitor??
        let sizeVisitor = ViewSetRectVisitor()
        _ = sizeVisitor.visit(graph)
        
        return graph
    }

    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }

    func testVisit() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let graph = prepare(view: view)

            XCTAssertNil(graph.dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(graph.dimensions[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when Text with content with linebreak") { (_) in
            let view = Text("hoge\nfuga")

            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)

            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSetRectVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)
            
            XCTAssertNil(graph.dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(graph.dimensions[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when TupleView<Text, Text, Text>") { (_) in
            let view = TupleView((
                Text("1"),
                Text("23"),
                Text("456")
            ))
            
            let graph = prepare(view: view)

            XCTAssertNil(graph.dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(graph.dimensions[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("23")
                Text("456")
            }
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)

            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSetRectVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)
            
            XCTAssertNil(graph.dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(graph.dimensions[explicit: VerticalAlignment.default])
        }
    }
    
}
