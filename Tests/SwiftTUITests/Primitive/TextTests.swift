//
//  TextTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/30.
//

import XCTest
@testable import SwiftTUI

class TextTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    func testSize() throws {
        XCTContext.runActivity(named: "when Text contains text") { (_) in
            let view = Text("text")
            
            let graph = prepareViewGraph(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "text".width, height: 1))
        }
        XCTContext.runActivity(named: "when Text with content with linebreak code") { (_) in
            let view = Text("text\ntext")
            
            let graph = prepareViewGraph(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)

            XCTAssertEqual(graph.rect.size, Size(width: "text".width, height: 2))
        }
    }

    
    func testPosition() {
        XCTContext.runActivity(named: "when Text has content") { (_) in
            let view = Text("hoge")
            let graph = prepareViewGraph(view: view)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
        }
    }
    
    func testContent() {
        XCTContext.runActivity(named: "when Text contains text") { (_) in
            let view = Text("text")
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            
            let content = driver.content()

            XCTAssertEqual(content, "text")
        }
        XCTContext.runActivity(named: "when Text with content with linebreak code") { (_) in
            let view = Text("text\ntext")
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(driver.storedString, "texttext")
        }
    }
    
    func testContentWithSmallScreen() {
        class SmallScreen: Screen {
            override var width: PhysicalDistance { return 1 }
            override var height: PhysicalDistance { return 1 }
        }
        mainScreen = SmallScreen()
        
        XCTContext.runActivity(named: "when Text contains text") { (_) in
            let view = Text("text")
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            
            let content = driver.content()
            
            XCTAssertEqual(content, "t")
        }

        XCTContext.runActivity(named: "when Text with content with linebreak code") { (_) in
            let view = Text("text\ntext")
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(driver.storedString, "tt")
        }
    }
}
