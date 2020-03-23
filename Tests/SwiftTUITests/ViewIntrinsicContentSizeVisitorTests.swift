//
//  ViewIntrinsicContentSizeVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/05.
//

import XCTest
@testable import SwiftTUI

class ViewIntrinsicContentSizeVisitorTests: XCTestCase {
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
            let view = Text("hoge")
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = view.accept(visitor: graphVisitor)
            let sizeVisitor = ViewIntrinsicContentSizeVisitor()
            let result = graph.accept(visitor: sizeVisitor)

            XCTAssertEqual(result, Size(width: "hoge".width, height: 1))
            XCTAssertEqual(result, graph.rect.size)
        }
        XCTContext.runActivity(named: "when Text with content with linebreak") { (_) in
            let view = Text("hoge\nfuga")

            let graphVisitor = ViewGraphSetVisitor()
            let graph = view.accept(visitor: graphVisitor)
            let sizeVisitor = ViewIntrinsicContentSizeVisitor()
            let result = graph.accept(visitor: sizeVisitor)

            XCTAssertEqual(result, Size(width: "hoge".width, height: 2))
            XCTAssertEqual(result, graph.rect.size)
        }
        XCTContext.runActivity(named: "when CustomView has Text") { (_) in
            let view = CustomView(body: Text("123"))

            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            let sizeVisitor = ViewIntrinsicContentSizeVisitor()
            let result = graph.accept(visitor: sizeVisitor)

            XCTAssertEqual(result, Size(width: "123".width, height: 1))
            XCTAssertEqual(result, graph.rect.size)
        }
        XCTContext.runActivity(named: "when Text with Modifier for _BackgroundModifier<Text>. _BackgroundModifier is not modifed size") { (_) in
            let view = Text("123").background(Color.red)
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            let sizeVisitor = ViewIntrinsicContentSizeVisitor()
            let result = graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(result, Size(width: "123".width, height: 1))
            XCTAssertEqual(result, graph.rect.size)
        }
        XCTContext.runActivity(named: "when Original Modifier") { (_) in
            struct Modifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.background(Color.red)
                }
            }
            
            let view = Text("1").modifier(Modifier())
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            let sizeVisitor = ViewIntrinsicContentSizeVisitor()
            let result = graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(result, Size(width: "1".width, height: 1))
            XCTAssertEqual(result, graph.rect.size)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
