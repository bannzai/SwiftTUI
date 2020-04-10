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
        XCTContext.runActivity(named: "using CustomView has boolean binding") { (_) in
            struct CustomView: View {
                @State var x: Bool
                var body: some View {
                    VStack {
                        if x {
                            Text("true")
                        } else {
                            Text("false")
                        }
                    }
                }
            }
            XCTContext.runActivity(named: "binding content to update") { (_) in
                let view = CustomView(x: true)
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
                
                let graph: ViewGraphImpl<CustomView> = prepareSizedGraph(view: view) as! ViewGraphImpl<CustomView>
                initial: do {
                    let visitor = ViewContentVisitor(driver: driver)
                    visitor.visit(graph)
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                }
                updated: do {
                    view.x = false
                    graph.callDynamicPropertyUpdate()
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("false"))
                }
                more: do {
                    view.x = true
                    graph.callDynamicPropertyUpdate()

                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                }
                
            }
        }
    }
    
}

