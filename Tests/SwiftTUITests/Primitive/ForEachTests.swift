//
//  ForEachTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/17.
//

import XCTest
@testable import SwiftTUI

class ForEachTests: XCTestCase {
    fileprivate struct Model: Identifiable {
        let id: Int
    }
    
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }

    func testChildrenPosition() throws {
        XCTContext.runActivity(named: "when ForEach with ClosedRange<Int>") { (_) in
            let view = ForEach((0..<2)) { (element: Int) in
                Text("\(element)")
            }
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.children.count, 2)
            graph.children.enumerated().forEach { (offset, child) in
                XCTAssertTrue(child.anyView is Text)
                XCTAssertEqual(child.rect.origin, Point(x: 0, y: offset))
            }
        }
        XCTContext.runActivity(named: "when ForEach with identifier model") { (_) in
            let view = ForEach((0..<2).map(Model.init(id:))) { element in
                Text("\(element.id)")
            }

            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.children.count, 2)
            graph.children.enumerated().forEach { (offset, child) in
                XCTAssertTrue(child.anyView is Text)
                XCTAssertEqual(child.rect.origin, Point(x: 0, y: offset))
            }
        }
    }
    
    func testContent() {
        XCTContext.runActivity(named: "when ForEach with ClosedRange<Int>") { (_) in
            let view = ForEach((0..<2)) { (element: Int) in
                Text("\(element)")
            }

            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()

            XCTAssertEqual(content, "01")
        }
        XCTContext.runActivity(named: "when ForEach with identifier model") { (_) in
            let view = ForEach((0..<2).map(Model.init(id:))) { element in
                Text("\(element.id)")
            }

            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            XCTAssertEqual(content, "01")
        }
    }
}
