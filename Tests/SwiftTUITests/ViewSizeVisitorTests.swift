//
//  ViewSizeVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/05.
//

import XCTest
@testable import SwiftTUI

class ViewSizeVisitorTests: XCTestCase {
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
    
    override func tearDown() {
        super.tearDown()
    }

    func testVisit() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let visitor = ViewSizeVisitor()
            let graph = ViewGraphImpl(view: Text("hoge"))
            let result = graph.accept(visitor: visitor)

            XCTAssertEqual(result, Size(width: "hoge".width, height: 1))
        }
        XCTContext.runActivity(named: "when Text with content with linebreak") { (_) in
            let visitor = ViewSizeVisitor()
            let graph = ViewGraphImpl(view: Text("hoge\nfuga"))
            let result = graph.accept(visitor: visitor)

            XCTAssertEqual(result, Size(width: "hoge".width, height: 2))
        }
        XCTContext.runActivity(named: "when TupleView<Text, Text, Text>") { (_) in
            let view = TupleView((
                Text("1"),
                Text("23"),
                Text("456")
            ))
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = view.accept(visitor: graphVisitor)
            graph.listType = .vertical
            let sizeVisitor = ViewSizeVisitor()
            let result = graph.accept(visitor: sizeVisitor)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(result, Size(width: "456".width, height: 3 + spacing))
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("23")
                Text("456")
            }
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = view.accept(visitor: graphVisitor)
            let sizeVisitor = ViewSizeVisitor()
            let result = graph.accept(visitor: sizeVisitor)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(result, Size(width: "456".width, height: 3 + spacing))
        }
        XCTContext.runActivity(named: "when CustomView has Text") { (_) in
            let view = CustomView(body: Text("123"))

            let graphVisitor = ViewGraphSetVisitor()
            let graph = view.accept(visitor: graphVisitor)
            let sizeVisitor = ViewSizeVisitor()
            let result = graph.accept(visitor: sizeVisitor)

            XCTAssertEqual(result, Size(width: "123".width, height: 1))
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
