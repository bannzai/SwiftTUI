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
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
