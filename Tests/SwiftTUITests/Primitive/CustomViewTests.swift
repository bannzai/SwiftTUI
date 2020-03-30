//
//  CustomViewTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/31.
//

import XCTest
@testable import SwiftTUI

fileprivate struct CustomView<Target: View>: View {
    let body: Target
}
class CustomViewTests: XCTestCase {
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
        XCTContext.runActivity(named: "when using _BackgroundModifier via CustomView") { (_) in
            struct Modifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.background(Color.red)
                }
            }
            
            let view = Text("1").modifier(Modifier())
            
            let graph = prepare(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "1".width, height: 1))
        }
    }
    
    
}
