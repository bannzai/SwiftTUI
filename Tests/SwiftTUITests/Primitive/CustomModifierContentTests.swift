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
fileprivate struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(Color.red)
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

    func testChlidrenPosition() throws {
        XCTContext.runActivity(named: "with border modifier") { _ in
            let view = Text("123").modifier(SingleBorderModifier())
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            XCTAssertTrue(graph.anyView is ModifiedContent<Text, SingleBorderModifier>)
            XCTAssertEqual(graph.rect.origin, .zero)

            let modifierGraph = graph.children[0]
            XCTAssertTrue(modifierGraph.anyView is ModifiedContent<_ViewModifier_Content<SingleBorderModifier>, _BorderModifier>)
            XCTAssertEqual(modifierGraph.rect.origin, .zero)
            
            let modifierContentGraph = modifierGraph.children[0]
            XCTAssertTrue(modifierContentGraph.anyView is _ViewModifier_Content<SingleBorderModifier>)
            XCTAssertEqual(modifierContentGraph.rect.origin, Point(x: defaultBorderWidth, y: defaultBorderWidth))

            let textGraph = modifierContentGraph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.origin, .zero)
        }
        XCTContext.runActivity(named: "with border.border.border modifier") { _ in
            let view = Text("123").modifier(ThreeBorderModifier())
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            XCTAssertTrue(graph.anyView is ModifiedContent<Text, ThreeBorderModifier>)
            XCTAssertEqual(graph.rect.origin, .zero)
            
            let blue = graph.children[0]
            XCTAssertTrue(blue.anyView is ModifiedContent<ModifiedContent<ModifiedContent<_ViewModifier_Content<ThreeBorderModifier>, _BorderModifier>, _BorderModifier>, _BorderModifier>)
            XCTAssertEqual(blue.rect.origin, .zero)

            let yellow = blue.children[0]
            XCTAssertTrue(yellow.anyView is ModifiedContent<ModifiedContent<_ViewModifier_Content<ThreeBorderModifier>, _BorderModifier>, _BorderModifier>)
            XCTAssertEqual(yellow.rect.origin, Point(x: defaultBorderWidth, y: defaultBorderWidth))

            let red = yellow.children[0]
            XCTAssertTrue(red.anyView is ModifiedContent<_ViewModifier_Content<ThreeBorderModifier>, _BorderModifier>)
            XCTAssertEqual(red.rect.origin, Point(x: defaultBorderWidth, y: defaultBorderWidth))

            let modifierContentGraph = red.children[0]
            XCTAssertTrue(modifierContentGraph.anyView is _ViewModifier_Content<ThreeBorderModifier>)
            XCTAssertEqual(modifierContentGraph.rect.origin, Point(x: defaultBorderWidth, y: defaultBorderWidth))

            let textGraph = modifierContentGraph.children[0]
            XCTAssertTrue(textGraph.anyView is Text)
            XCTAssertEqual(textGraph.rect.origin, .zero)
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
        
        XCTContext.runActivity(named: "with background modifier ") { (_) in
            let view = Text("1").modifier(BackgroundModifier())
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertEqual("1", result)
            
            XCTAssertTrue(driver.storedBackgroundColors.contains(.red))
            XCTAssertEqual(driver.storedBackgroundColors.last, Style.Color.background.color)
        }
    }

}
