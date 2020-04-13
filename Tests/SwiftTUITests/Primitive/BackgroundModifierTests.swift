//
//  BackgroundModifierTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/31.
//

import XCTest
@testable import SwiftTUI

class BackgroundModifierTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    func testSize() throws {
        XCTContext.runActivity(named: "when Text with Modifier for _BackgroundModifier<Text>. _BackgroundModifier is not modifed size") { (_) in
            let view = Text("123").background(Color.red)
            
            let graph = prepareViewGraph(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width, height: 1))
        }
    }
    
    func testChildrenPosition() throws {
        XCTContext.runActivity(named: "when ModifiedContent<Text, _BackgroundModifier>") { _ in
            let view = Text("123").background(Color.blue)
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let textGraph = graph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            
            XCTAssertEqual(textGraph.rect.origin, .zero)
        }
    }
    
    
    func testContent() {
        XCTContext.runActivity(named: "when Double _BackgroundModifier. ModifierdContent<Text, _BackgroundModifier<_BackgroundModifier<Color>>") { (_) in
            let view = Text("1").background(Color.red).background(Color.blue)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertEqual("1", result)
            
            XCTAssertAmbiguouseOrder(driver.storedBackgroundColors, [.blue, .red])
            XCTAssertEqual(driver.storedBackgroundColors.last, Style.Color.background.color)
        }
    }
}
