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
            struct BorderModifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.border(.red)
                }
            }
            let view = Text("text").modifier(BorderModifier())
            
            let graph = prepareViewGraph(view: view)
            graph.accept(visitor: ViewSetRectVisitor())
            

            XCTAssertEqual(graph.rect.size, Size(width: "text".width + 2, height: "text".height + 1))
            
            let borderModifier = graph.children[0]
            XCTAssertTrue(borderModifier.anyView is ModifiedContent<Text, _BorderModifier>)
            XCTAssertEqual(borderModifier.rect.size, Size(width: "text".width + 2, height: "text".height + 2))
        }
    }

}
