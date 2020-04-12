//
//  CustomModifierContentTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/12.
//

import XCTest
@testable import SwiftTUI

fileprivate struct SingleBorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.border(.red)
    }
}
fileprivate struct ThreeBorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.border(.red).border(.yellow).border(.blue)
    }
}
class CustomModifierContentTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }

    func testSize() throws {
        XCTContext.runActivity(named: "with border modifier") { _ in
            let view = Text("text").modifier(SingleBorderModifier())
            
            let graph = prepareViewGraph(view: view)
            graph.accept(visitor: ViewSetRectVisitor())
            XCTAssertTrue(graph.anyView is ModifiedContent<Text, SingleBorderModifier>)
            XCTAssertEqual(graph.rect.size, Size(width: "text".width + 2, height: "text".height + 2))
            
            let wrappedModifier = graph.children[0]
            XCTAssertTrue(wrappedModifier.anyView is ModifiedContent<_ViewModifier_Content<SingleBorderModifier>, _BorderModifier>)
            XCTAssertEqual(wrappedModifier.rect.size, Size(width: "text".width + 2, height: "text".height + 2))
        }
        
        XCTContext.runActivity(named: "with border.border.border modifier") { _ in
            let view = Text("text").modifier(ThreeBorderModifier())

            let graph = prepareViewGraph(view: view)
            graph.accept(visitor: ViewSetRectVisitor())
            XCTAssertTrue(graph.anyView is ModifiedContent<Text, ThreeBorderModifier>)
            XCTAssertEqual(graph.rect.size, Size(width: "text".width + 2 + 2 + 2, height: "text".height + 2 + 2 + 2))

            let blue = graph.children[0]
            XCTAssertTrue(blue.anyView is ModifiedContent<ModifiedContent<ModifiedContent<_ViewModifier_Content<ThreeBorderModifier>, _BorderModifier>, _BorderModifier>, _BorderModifier>)
            XCTAssertEqual(blue.rect.size, Size(width: "text".width + 2 + 2 + 2, height: "text".height + 2 + 2 + 2))
            
            let yellow = blue.children[0]
            XCTAssertTrue(yellow.anyView is ModifiedContent<ModifiedContent<_ViewModifier_Content<ThreeBorderModifier>, _BorderModifier>, _BorderModifier>)
            XCTAssertEqual(yellow.rect.size, Size(width: "text".width + 2 + 2, height: "text".height + 2 + 2))
            
            let red = yellow.children[0]
            XCTAssertTrue(red.anyView is ModifiedContent<_ViewModifier_Content<ThreeBorderModifier>, _BorderModifier>)
            XCTAssertEqual(red.rect.size, Size(width: "text".width + 2, height: "text".height + 2))
        }
    }
    
    func testContent() throws {
        XCTContext.runActivity(named: "with border modifier") { _ in
            let view = Text("text").modifier(SingleBorderModifier())
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            graph.accept(visitor: ViewContentVisitor(driver: driver))
            
            let content = driver.content()
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter
            
            XCTAssertTrue(driver.storedForegroundColors.contains(.red))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), 4)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), 1 * 2)
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), 4 * 2)
            XCTAssertTrue(content.contains("text"))
        }
        
        XCTContext.runActivity(named: "with border.border.border modifier") { _ in
            let view = Text("text").modifier(ThreeBorderModifier())
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            graph.accept(visitor: ViewContentVisitor(driver: driver))
            
            let content = driver.content()
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter
            
            XCTAssertTrue(driver.storedForegroundColors.contains(.red))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), 4 * 3)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), 1 * 2 + 3 * 2 + 5 * 2)
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), 4 * 2 + 6 * 2 + 8 * 2)
            XCTAssertTrue(content.contains("text"))
        }
    }

}
