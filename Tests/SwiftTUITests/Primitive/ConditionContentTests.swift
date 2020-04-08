//
//  ConditionContentTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import XCTest
@testable import SwiftTUI

class ConditionContentTests: XCTestCase {
    func testContent() {
        XCTContext.runActivity(named: "when true pattern") { (_) in
            let flag = true
            let view = VStack {
                if flag {
                    Text("true")
                } else {
                    Text("false")
                }
            }
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            visitor.visit(graph)
            
            let content = driver.content()
            XCTAssertTrue(content.contains("true"))
        }
        XCTContext.runActivity(named: "when false pattern") { (_) in
            let flag = false
            let view = VStack {
                if flag {
                    Text("true")
                } else {
                    Text("false")
                }
            }
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            visitor.visit(graph)
            
            let content = driver.content()
            XCTAssertTrue(content.contains("false"))
        }
    }
}
