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
            struct CustomView: View {
                @Binding var x: Bool
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
                let location = StoredLocation(value: true)
                var binding = Binding(location: location)
                let view = CustomView(x: binding)
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

                initial: do {
                    let graph = prepareSizedGraph(view: view)
                    let visitor = ViewContentVisitor(driver: driver)
                    visitor.visit(graph)
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                }
                updated: do {
                    binding.wrappedValue = false
                    binding.update()
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("false"))
                }
                more: do {
                    binding.wrappedValue = true
                    binding.update()
                    
                    let content = driver.content()
                    XCTAssertTrue(content.contains("true"))
                }

            }
        }
    }

}
