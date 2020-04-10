//
//  StateTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/11.
//

import XCTest
@testable import SwiftTUI

class StateTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    func testUpdate() {
        XCTContext.runActivity(named: "using CustomView has boolean state") { (_) in
            XCTContext.runActivity(named: "content has state and update") { (_) in
                let view = BooleanStatableView(state: true)
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
                
                let graph: ViewGraphImpl<BooleanStatableView> = prepareSizedGraph(view: view) as! ViewGraphImpl<BooleanStatableView>
                initial: do {
                    driver.clear()
                    
                    let visitor = ViewContentVisitor(driver: driver)
                    visitor.visit(graph)
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                }
                updated: do {
                    driver.clear()
                    
                    view.state = false
                    graph.callDynamicPropertyUpdate()
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("false"))
                }
                more: do {
                    driver.clear()
                    
                    view.state = true
                    graph.callDynamicPropertyUpdate()

                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                }
                
            }
        }
    }
    func testUpdateWithBinding() {
        XCTContext.runActivity(named: "using CustomView has boolean state") { (_) in
            XCTContext.runActivity(named: "content has state and state view update") { (_) in
                let view = BooleanStatableViewHasBindableView(state: true)
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
                
                let graph: ViewGraphImpl<BooleanStatableViewHasBindableView> = prepareSizedGraph(view: view) as! ViewGraphImpl<BooleanStatableViewHasBindableView>
                initial: do {
                    driver.clear()
                    
                    let visitor = ViewContentVisitor(driver: driver)
                    visitor.visit(graph)

                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                    XCTAssertFalse(content.contains("false"))
                }
                updated: do {
                    driver.clear()
                    
                    view.state = false
                    graph.callDynamicPropertyUpdate()
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("false"))
                    XCTAssertFalse(content.contains("true"))
                }
                more: do {
                    driver.clear()
                    
                    view.state = true
                    graph.callDynamicPropertyUpdate()
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                    XCTAssertFalse(content.contains("false"))
                }
            }
        }
    }
}

