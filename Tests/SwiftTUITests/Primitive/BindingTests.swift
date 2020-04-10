//
//  BindingTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import XCTest
@testable import SwiftTUI

class BindingTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    func testUpdate() {
        XCTContext.runActivity(named: "using CustomView has boolean binding") { (_) in
            XCTContext.runActivity(named: "binding content to update") { (_) in
                let location = StoredLocation(value: true)
                let binding = Binding(location: location)
                let view = BooleanBindableView(binding: binding)
                let driver = Driver()
                sharedDrawer = TestDrawer.init(draw: {
                    let graphVisitor = ViewGraphSetVisitor()
                    let graph = graphVisitor.visit(view)
                    
                    let sizeVisitor = ViewSetRectVisitor()
                    _ = sizeVisitor.visit(graph)
                    
                    configureView: do {
                        let visitor = ViewContentVisitor(driver: driver)
                        visitor.visit(graph)
                    }
                })

                let graph = prepareSizedGraph(view: view) as! ViewGraphImpl<BooleanBindableView>
                initial: do {
                    driver.clear()
                    
                    let visitor = ViewContentVisitor(driver: driver)
                    visitor.visit(graph)
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                }
                updated: do {
                    driver.clear()
                    
                    binding.wrappedValue = false
                    graph.callDynamicPropertyUpdate()
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("false"))
                }
                more: do {
                    driver.clear()
                    
                    binding.wrappedValue = true
                    graph.callDynamicPropertyUpdate()

                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                }

            }
        }
    }

}
