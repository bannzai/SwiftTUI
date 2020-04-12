//
//  ModifierContentTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/12.
//

import XCTest
@testable import SwiftTUI

class ModifierContentTests: XCTestCase {
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

}
