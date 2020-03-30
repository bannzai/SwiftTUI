//
//  ViewSetRectVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/05.
//

import XCTest
@testable import SwiftTUI

class ViewSetRectVisitorTests: XCTestCase {
    struct CustomView<Target: View>: View {
        let body: Target
    }
    
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testVisit() {
        XCTContext.runActivity(named: "when Original Modifier") { (_) in
            struct Modifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.background(Color.red)
                }
            }
            
            let view = Text("1").modifier(Modifier())
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "1".width, height: 1))
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
