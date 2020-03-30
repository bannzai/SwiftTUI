//
//  ViewContainerContentSizeVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/22.
//

import XCTest
@testable import SwiftTUI

class ViewContainerContentSizeVisitorTests: XCTestCase {
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
    
    func testAccept() {
        XCTContext.runActivity(named: "when TupleView<Text, Text, Text>") { (_) in
            let view = TupleView((
                Text("1"),
                Text("23"),
                Text("456")
            ))
            
            let graph = prepare(view: view)

            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: "456".width, height: elementCount + spacing))
        }
    }
}
