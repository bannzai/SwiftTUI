//
//  ConditionContentTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import XCTest
@testable import SwiftTUI

class ConditionalContentTests: XCTestCase {
    func testRelation() {
        XCTContext.runActivity(named: "when true pattern") { (_) in
            let flag = true
            let view = VStack {
                if flag {
                    Text("true")
                } else {
                    Text("false")
                }
            }
            let graph = prepareViewGraph(view: view)
            XCTAssertEqual(graph.children.count, 1)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
        }
    }
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
