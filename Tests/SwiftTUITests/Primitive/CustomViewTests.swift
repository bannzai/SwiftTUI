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
        sharedCursor = TestCursor()
    }
    
    var testSharedCursor: TestCursor { sharedCursor as! TestCursor }

    func testSize() throws {
        XCTContext.runActivity(named: "when using _BackgroundModifier via CustomView") { (_) in
            struct Modifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.background(Color.red)
                }
            }
            
            let view = Text("1").modifier(Modifier())
            
            let graph = prepareViewGraph(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "1".width, height: 1))
        }
        XCTContext.runActivity(named: "when CustomView has VStack<Text>") { (_) in
            let view = CustomView(body: VStack { Text("123") })
            
            let graph = prepareViewGraph(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width, height: 1))
        }
        XCTContext.runActivity(named: "when CustomView has VStack<TupleView<CustomView<Text>, CustomView<Text>>>") { (_) in
            let view = CustomView(body: VStack {
                CustomView(body: Text("123"))
                CustomView(body: Text("456"))
            })
            
            let graph = prepareViewGraph(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)

            let elementCount = 2
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: "456".width, height: 2 + spacing))
        }
        XCTContext.runActivity(named: "when CustomView has VStack<TupleView<Text, Text, Text>>") { (_) in
            let view = CustomView(body: VStack {
                Text("123")
                Text("456")
                Text("789")
            })
            
            let graph = prepareViewGraph(view: view)
            let sizeVisitor = ViewSetRectVisitor()
            graph.accept(visitor: sizeVisitor)

            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: "456".width, height: 3 + spacing))
        }
    }
    
    func testContent() {
        XCTContext.runActivity(named: "when CustomView has VStack<CustomView<Text>, CustomView<Text>>") { (_) in
            let view = CustomView(body: VStack {
                CustomView(body: Text("123"))
                CustomView(body: Text("456"))
            })
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertTrue(result.contains("123"))
            XCTAssertTrue(result.contains("456"))
            XCTAssertAmbiguouseOrder(testSharedCursor.yHistory, [0, ViewVisitorListOption.vertical.defaultSpace + "123".height])
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("2")
                Text("3")
            }
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertTrue(result.contains("1"))
            XCTAssertTrue(result.contains("2"))
            XCTAssertTrue(result.contains("3"))
            XCTAssertAmbiguouseOrder(testSharedCursor.yHistory, [0, ViewVisitorListOption.vertical.defaultSpace + "1".height + "123".height, ViewVisitorListOption.vertical.defaultSpace + "1".height + "2".height])
        }
        XCTContext.runActivity(named: "when CustomView has VStack<CustomView<Text>>") { (_) in
            let view = CustomView(body: VStack { CustomView(body: Text("123")) } )
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertEqual(result, "123")
        }
        XCTContext.runActivity(named: "when CustomView has EmptyView") { (_) in
            let view = CustomView(body: EmptyView())
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertEqual(result, "")
        }
        XCTContext.runActivity(named: "when CustomView has VStack<Text>") { (_) in
            let view = CustomView(body: VStack { Text("123") } )
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            XCTAssertEqual(result, "123")
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
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertTrue(result.contains("1"))
            XCTAssertTrue(result.contains("2"))
            XCTAssertTrue(result.contains("3"))
            
            XCTAssertAmbiguouseOrder(testSharedCursor.xHistory, [0, 0, 0])
            XCTAssertAmbiguouseOrder(testSharedCursor.yHistory, [0, ViewVisitorListOption.vertical.defaultSpace + "1".height, ViewVisitorListOption.vertical.defaultSpace + "1".height + "23".height])
            
            XCTAssertTrue(driver.storedBackgroundColors.contains(.red))
            XCTAssertEqual(driver.storedBackgroundColors.last, Style.Color.background.color)
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
        }
    }

}
