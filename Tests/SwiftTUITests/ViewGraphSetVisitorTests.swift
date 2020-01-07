//
//  ViewGraphSetVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/06.
//

import XCTest
@testable import SwiftTUI

class ViewGraphSetVisitorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVisit() {
        // TODO: alignmentやlisttypeのテスト？
        
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("123")
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view: view)
            
            XCTAssertTrue(graph.anyView is Text)
            XCTAssertTrue(graph.children.isEmpty)
            XCTAssertTrue(graph.isRoot)
            XCTAssertFalse(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
        }
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
