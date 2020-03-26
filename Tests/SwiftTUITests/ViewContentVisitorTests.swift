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
    
    class Driver: DrawableDriver {
        var callBag: [StaticString] = []
        var storedRunes: [Rune] = []
        func add(rune: Rune) {
            callBag.append(#function)
            storedRunes.append(rune)
        }
        
        var storedForegroundColors: [Color] = []
        func setForegroundColor(_ color: Color) {
            callBag.append(#function)
            storedForegroundColors.append(color)
        }
        
        var storedBackgroundColors: [Color] = []
        func setBackgroundColor(_ color: Color) {
            callBag.append(#function)
            storedBackgroundColors.append(color)
        }
        
        var keepForegroundColor: Color?
        var keepBackgroundColor: Color?
        
        func content() -> String {
            callBag.append(#function)
            return storedRunes.compactMap(Unicode.Scalar.init)
                .map(Character.init)
                .map(String.init)
                .reduce("", +)
        }
        
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
        let sizeVisitor = ViewIntrinsicContentSizeVisitor()
        _ = sizeVisitor.visit(graph)
        
        let dimensionsVisitor = ViewDimensionsVisitor()
        _ = dimensionsVisitor.visit(graph)
        
        let positionSetVisitor = ViewPositionSetVisitor()
        _ = positionSetVisitor.visit(graph)
        
        let containerContentSizeVisitor = ViewContainerContentSizeVisitor()
        containerContentSizeVisitor.visit(graph)
        
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
    }
}
