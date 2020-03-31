//
//  ViewContentVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import XCTest
import Foundation
import Runtime
@testable import SwiftTUI

class ViewContentVisitorTests: XCTestCase {
    struct CustomView<Target: View>: View {
        let body: Target
    }
    
    class DummyScreen: Screen {
        override var columns: PhysicalDistance { 100 }
        override var rows: PhysicalDistance { 100 }
    }
    
    private func prepare<T: View>(view: T, viewListOption: ViewVisitorListOption = .vertical) -> ViewGraph {
        testSharedCursor.reset()

        let graphVisitor = ViewGraphSetVisitor()
        let graph = graphVisitor.visit(view)
        graph.listType = viewListOption
        
        // FIXME: Remove Size Visitor??
        let sizeVisitor = ViewSetRectVisitor()
        _ = sizeVisitor.visit(graph)

        return graph
    }
    
    override func setUp() {
        super.setUp()
        
        sharedCursor = TestCursor()
        mainScreen = DummyScreen.init()
    }
    
    var testSharedCursor: TestCursor { sharedCursor as! TestCursor }
    
    func testViewContentVisitor() {
        XCTContext.runActivity(named: "when CustomView has VStack<CustomView<Text>, CustomView<Text>>") { (_) in
            let view = CustomView(body: VStack {
                CustomView(body: Text("123"))
                CustomView(body: Text("456"))
            })
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertTrue(result.contains("123"))
            XCTAssertEqual(testSharedCursor.yHistory[0], 0)
            XCTAssertTrue(result.contains("456"))
            XCTAssertEqual(testSharedCursor.yHistory[1], ViewVisitorListOption.vertical.defaultSpace + "123".height)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("2")
                Text("3")
            }
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertTrue(result.contains("1"))
            XCTAssertEqual(testSharedCursor.yHistory[0], 0)
            XCTAssertTrue(result.contains("2"))
            XCTAssertEqual(testSharedCursor.yHistory[1], ViewVisitorListOption.vertical.defaultSpace + "1".height)
            XCTAssertTrue(result.contains("3"))
            XCTAssertEqual(testSharedCursor.yHistory[2], ViewVisitorListOption.vertical.defaultSpace + "1".height + "2".height)
        }
        XCTContext.runActivity(named: "when CustomView has VStack<CustomView<Text>>") { (_) in
            let view = CustomView(body: VStack { CustomView(body: Text("123")) } )
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertEqual(result, "123")
        }
        XCTContext.runActivity(named: "when CustomView has EmptyView") { (_) in
            let view = CustomView(body: EmptyView())
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertEqual(result, "")
        }
        XCTContext.runActivity(named: "when CustomView has VStack<Text>") { (_) in
            let view = CustomView(body: VStack { Text("123") } )
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertEqual(result, "123")
        }
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertEqual("hoge", result)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<_BackgroundModifier<Text>, Text, _BackgroundModifier<Text>>") { (_) in
            let view = VStack {
                Text("1")
                    .foregroundColor(.blue)
                Text("2")
                Text("3")
                    .background(Color.red)
            }
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertTrue(result.contains("1"))
            XCTAssertEqual(testSharedCursor.yHistory[0], 0)
            XCTAssertTrue(result.contains("2"))
            XCTAssertEqual(testSharedCursor.yHistory[1], ViewVisitorListOption.vertical.defaultSpace + "1".height)
            XCTAssertTrue(result.contains("3"))
            XCTAssertEqual(testSharedCursor.yHistory[2], ViewVisitorListOption.vertical.defaultSpace + "1".height + "2".height)

            XCTAssertTrue(driver.storedBackgroundColors.contains(.red))
            XCTAssertEqual(driver.storedBackgroundColors.last, Style.Color.background.color)
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
        }
        
        XCTContext.runActivity(named: "when Double _BackgroundModifier. _BackgroundModifier<_BackgroundModifier<Text>>") { (_) in
            let view = Text("1").background(Color.red).background(Color.blue)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertEqual("1", result)

            XCTAssertEqual(driver.storedBackgroundColors[0..<2], [.blue, .red])
            XCTAssertEqual(driver.storedBackgroundColors[2], Style.Color.background.color)
        }
        XCTContext.runActivity(named: "when Original Modifier") { (_) in
            struct Modifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.background(Color.red)
                }
            }
            
            let view = Text("1").modifier(Modifier())
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertEqual("1", result)

            XCTAssertTrue(driver.storedBackgroundColors.contains(.red))
            XCTAssertEqual(driver.storedBackgroundColors.last, Style.Color.background.color)
        }
        XCTContext.runActivity(named: "when VStack(alignment: .trailing) contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                Text("23")
                Text("456")
            }
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertTrue(result.contains("1"))
            XCTAssertEqual(testSharedCursor.xHistory[0], 2)
            XCTAssertEqual(testSharedCursor.yHistory[0], 0)
            XCTAssertTrue(result.contains("23"))
            XCTAssertEqual(testSharedCursor.xHistory[1], 1)
            XCTAssertEqual(testSharedCursor.yHistory[1], ViewVisitorListOption.vertical.defaultSpace + "1".height)
            XCTAssertTrue(result.contains("456"))
            XCTAssertEqual(testSharedCursor.xHistory[2], 0)
            XCTAssertEqual(testSharedCursor.yHistory[2], ViewVisitorListOption.vertical.defaultSpace + "1".height + "23".height)
        }
        XCTContext.runActivity(named: "when VStack(alignment: .trailing) contains TupleView<_AlignmentWritingModifier<Text>, Text, Text>") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("Hello")
                    .alignmentGuide(.trailing, computeValue: { _ in return 2 })
                Text(",")
                Text("World")
            }
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertTrue(result.contains("Hello"))
            XCTAssertEqual(testSharedCursor.xHistory[0], 3)
            XCTAssertEqual(testSharedCursor.yHistory[0], 0)
            XCTAssertTrue(result.contains(","))
            XCTAssertEqual(testSharedCursor.xHistory[1], 4)
            XCTAssertEqual(testSharedCursor.yHistory[1], ViewVisitorListOption.vertical.defaultSpace + "Hello".height)
            XCTAssertTrue(result.contains("World"))
            XCTAssertEqual(testSharedCursor.xHistory[2], 0)
            XCTAssertEqual(testSharedCursor.yHistory[2], ViewVisitorListOption.vertical.defaultSpace + "Hello".height + ",".height)
            
            XCTAssertEqual(graph.rect.size.width, 8)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<_AlignmentWritingModifier<Text>, Text, Text> when .leading alignment and specity negative value") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .alignmentGuide(.leading, computeValue: { _ in return -1 })
                Text(",")
                Text("World")
            }
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepare(view: view)
            visitor.visit(graph)
            
            let result = driver.content()
            
            XCTAssertTrue(result.contains("Hello"))
            XCTAssertEqual(testSharedCursor.xHistory[0], 1)
            XCTAssertEqual(testSharedCursor.yHistory[0], 0)
            XCTAssertTrue(result.contains(","))
            XCTAssertEqual(testSharedCursor.xHistory[1], 0)
            XCTAssertEqual(testSharedCursor.yHistory[1], ViewVisitorListOption.vertical.defaultSpace + "Hello".height)
            XCTAssertTrue(result.contains("World"))
            XCTAssertEqual(testSharedCursor.xHistory[2], 0)
            XCTAssertEqual(testSharedCursor.yHistory[2], ViewVisitorListOption.vertical.defaultSpace + "Hello".height + ",".height)
            
            XCTAssertEqual(graph.rect.size.width, 6)
        }
    }
}
