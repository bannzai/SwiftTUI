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
        func prepare<T: View>(view: T) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            return graph
        }
        XCTContext.runActivity(named: "when Text with Modifier for _BackgroundModifier<Text>. _BackgroundModifier is not modifed size") { (_) in
            let view = Text("123").background(Color.red)
            
            let graph = prepare(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width, height: 1))
        }
    }
    
    
}
