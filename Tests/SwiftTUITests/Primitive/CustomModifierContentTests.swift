//
//  CustomModifierContentTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/12.
//

import XCTest
@testable import SwiftTUI

class CustomModifierContentTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }

    func testSize() throws {
        XCTContext.runActivity(named: "with border modifier") { _ in
            struct Modifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.border(.red)
                }
            }
            let view = Text("text").modifier(Modifier())
            
            let graph = prepareViewGraph(view: view)
            graph.accept(visitor: ViewSetRectVisitor())
            XCTAssertTrue(graph.anyView is ModifiedContent<Text, Modifier>)
            XCTAssertEqual(graph.rect.size, Size(width: "text".width + 2, height: "text".height + 2))
            
            let wrappedModifier = graph.children[0]
            XCTAssertTrue(wrappedModifier.anyView is ModifiedContent<_ViewModifier_Content<Modifier>, _BorderModifier>)
            XCTAssertEqual(wrappedModifier.rect.size, Size(width: "text".width + 2, height: "text".height + 2))
        }
        
    }
    
    func test_playground() {
        XCTContext.runActivity(named: "with border.border.border modifier") { _ in
            struct Modifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.border(.red).border(.yellow).border(.blue)
                }
            }
            let view = Text("text").modifier(Modifier())

            let graph = prepareViewGraph(view: view)
            graph.accept(visitor: ViewSetRectVisitor())
            XCTAssertTrue(graph.anyView is ModifiedContent<Text, Modifier>)
            XCTAssertEqual(graph.rect.size, Size(width: "text".width + 2 + 2 + 2, height: "text".height + 2 + 2 + 2))

            let blue = graph.children[0]
            XCTAssertTrue(blue.anyView is ModifiedContent<ModifiedContent<ModifiedContent<_ViewModifier_Content<Modifier>, _BorderModifier>, _BorderModifier>, _BorderModifier>)
            XCTAssertEqual(blue.rect.size, Size(width: "text".width + 2 + 2 + 2, height: "text".height + 2 + 2 + 2))
            
            let yellow = blue.children[0]
            XCTAssertTrue(yellow.anyView is ModifiedContent<ModifiedContent<_ViewModifier_Content<Modifier>, _BorderModifier>, _BorderModifier>)
            XCTAssertEqual(yellow.rect.size, Size(width: "text".width + 2 + 2, height: "text".height + 2 + 2))
            
            let red = yellow.children[0]
            XCTAssertTrue(red.anyView is ModifiedContent<_ViewModifier_Content<Modifier>, _BorderModifier>)
            XCTAssertEqual(red.rect.size, Size(width: "text".width + 2, height: "text".height + 2))
        }
    }
    

}
