//
//  ForEachTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/17.
//

import XCTest
@testable import SwiftTUI

class ForEachTests: XCTestCase {
    fileprivate struct Model: Identifiable {
        let id: Int
    }
    
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    func testSize() throws {
        XCTContext.runActivity(named: "when ForEach with ClosedRange<Int>") { (_) in
            let view = ForEach((0..<2)) { (element: Int) in
                Text("\(element)")
            }

            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: 1, height: "0".height + "1".height))
        }
        XCTContext.runActivity(named: "when ForEach with identifier model") { (_) in
            let view = ForEach((0..<2).map(Model.init(id:))) { element in
                Text("\(element.id)")
            }

            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "0".width, height: "0".height + "1".height))
        }
        XCTContext.runActivity(named: "when VStack<ForEach<TupleView<(Text, Text)>>> with ClosedRange<Int>") { (_) in
            let view = VStack {
                ForEach((0..<2)) { (element: Int) in
                    Text("\(element)")
                    Text("X")
                }
            }
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: 1, height: (1 + "X".height) * 2))
        }
        XCTContext.runActivity(named: "when ForEach<TupleView<(Text, Text)>> with ClosedRange<Int>") { (_) in
            let view = ForEach((0..<2)) { (element: Int) in
                Text("\(element)")
                Text("X")
            }
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: 1, height: (1 + "X".height) * 2))
        }
    }
    
    func testChildrenRect() throws {
        XCTContext.runActivity(named: "when ForEach with ClosedRange<Int>") { (_) in
            let view = ForEach((0..<2)) { (element: Int) in
                Text("\(element)")
            }
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.children.count, 2)
            graph.children.enumerated().forEach { (offset, child) in
                XCTAssertTrue(child.anyView is Text)
                XCTAssertEqual(child.rect.origin, Point(x: 0, y: offset))
                XCTAssertEqual(child.rect.size, Size(width: 1, height: 1))
            }
        }
        XCTContext.runActivity(named: "when ForEach with identifier model") { (_) in
            let view = ForEach((0..<2).map(Model.init(id:))) { element in
                Text("\(element.id)")
            }

            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.children.count, 2)
            graph.children.enumerated().forEach { (offset, child) in
                XCTAssertTrue(child.anyView is Text)
                XCTAssertEqual(child.rect.origin, Point(x: 0, y: offset))
                XCTAssertEqual(child.rect.size, Size(width: 1, height: 1))
            }
        }
        XCTContext.runActivity(named: "when VStack<ForEach<Text>> with ClosedRange<Int>") { (_) in
            let view = VStack {
                ForEach((0..<2)) { (element: Int) in
                    Text("\(element)")
                }
            }
            
            let vstackGraph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            vstackGraph.accept(visitor: visitor)
            XCTAssertEqual(vstackGraph.children.count, 2)
            
            vstackGraph.children.enumerated().forEach { (offset, child) in
                XCTAssertTrue(child.anyView is Text)
                XCTAssertEqual(child.rect.origin, Point(x: 0, y: offset))
                XCTAssertEqual(child.rect.size, Size(width: 1, height: 1))
            }
        }
        XCTContext.runActivity(named: "when VStack<ForEach<TupleView<(Text, Text)>>> with ClosedRange<Int>") { (_) in
            let view = VStack {
                ForEach((0..<2)) { (element: Int) in
                    Text("\(element)")
                    Text("X")
                }
            }
            
            let vstackGraph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            vstackGraph.accept(visitor: visitor)
            XCTAssertEqual(vstackGraph.children.count, 4)
            
            vstackGraph.children.enumerated().forEach { (offset, child) in
                XCTAssertTrue(child.anyView is Text)
                XCTAssertEqual(child.rect.origin, Point(x: 0, y: offset))
                XCTAssertEqual(child.rect.size, Size(width: 1, height: 1))
            }
        }
        XCTContext.runActivity(named: "when ForEach<TupleView<(Text, Text)>> with ClosedRange<Int>") { (_) in
            let view = ForEach((0..<2)) { (element: Int) in
                Text("\(element)")
                Text("X")
            }
            
            let graph = prepareViewGraph(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            XCTAssertEqual(graph.children.count, 4)
            
            graph.children.enumerated().forEach { (offset, child) in
                XCTAssertTrue(child.anyView is Text)
                XCTAssertEqual(child.rect.origin, Point(x: 0, y: offset))
                XCTAssertEqual(child.rect.size, Size(width: 1, height: 1))
                
                child.children.enumerated().forEach { (offset, child) in
                    XCTAssertTrue(child.anyView is Text)
                    XCTAssertEqual(child.rect.origin, Point(x: 0, y: offset))
                    XCTAssertEqual(child.rect.size, Size(width: 1, height: 1))
                }
            }
        }
    }
    
    func testContent() {
        XCTContext.runActivity(named: "when ForEach with ClosedRange<Int>") { (_) in
            let view = ForEach((0..<2)) { (element: Int) in
                Text("\(element)")
            }

            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()

            XCTAssertEqual(content, "01")
        }
        XCTContext.runActivity(named: "when ForEach with identifier model") { (_) in
            let view = ForEach((0..<2).map(Model.init(id:))) { element in
                Text("\(element.id)")
            }

            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            XCTAssertEqual(content, "01")
        }
        XCTContext.runActivity(named: "when VStack<ForEach<Text>> with ClosedRange<Int>") { (_) in
            let view = VStack {
                ForEach((0..<2)) { (element: Int) in
                    Text("\(element)")
                }
            }
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            XCTAssertEqual(content.filter { $0 == "0" }.count, 1)
            XCTAssertEqual(content.filter { $0 == "1" }.count, 1)
        }
        XCTContext.runActivity(named: "when VStack<ForEach<TupleView<(Text, Text)>>> with ClosedRange<Int>") { (_) in
            let view = VStack {
                ForEach((0..<2)) { (element: Int) in
                    Text("\(element)")
                    Text("X")
                }
            }
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            XCTAssertEqual(content.filter { $0 == "0" }.count, 1)
            XCTAssertEqual(content.filter { $0 == "1" }.count, 1)
            XCTAssertEqual(content.filter { $0 == "X" }.count, 2)
        }
        XCTContext.runActivity(named: "when ForEach<TupleView<(Text, Text)>> with ClosedRange<Int>") { (_) in
            let view = ForEach((0..<2)) { (element: Int) in
                Text("\(element)")
                Text("X")
            }
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            XCTAssertEqual(content.filter { $0 == "0" }.count, 1)
            XCTAssertEqual(content.filter { $0 == "1" }.count, 1)
            XCTAssertEqual(content.filter { $0 == "X" }.count, 2)
        }
    }
    
    func testContentWithBorderModifier() {
        XCTContext.runActivity(named: "when ForEach. But ForEach is not contained ParentView(In other words ForEach is RootView pattern)") { (_) in
            // NOTE: See also https://github.com/bannzai/SwiftTUI/pull/14#issuecomment-615544848
            let view = ForEach((0..<2)) { element in
                Text("\(element)")
            }
            .border(Color.blue)
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter
            
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), 1 * 4)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), 2 * 2)
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), 1 * 2)
            XCTAssertTrue(content.contains("0"))
            XCTAssertTrue(content.contains("1"))
        }
        XCTContext.runActivity(named: "when ForEach with identifier model with border modifier. But ForEach is contained ParentView") { (_) in
            let view = VStack {
                ForEach((0..<2).map(Model.init(id:))) { element in
                    Text("\(element.id)")
                }
                .border(Color.blue)
            }
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter
            
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), 1 * 4 * 2)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), 2 * 2)
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), 2 * 2)
            XCTAssertTrue(content.contains("0"))
            XCTAssertTrue(content.contains("1"))
        }
        XCTContext.runActivity(named: "when ForEach<TupleView<(Text, Text)>>. But ForEach is contained ParentView. ") { (_) in
            let view = VStack {
                ForEach((0..<2)) { element in
                    Text("\(element)")
                    Text("X")
                }
                .border(Color.blue)
            }
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter
            
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), 1 * 4 * 2 * 2)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), 2 * 2 * 2)
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), 2 * 2 * 2)
            XCTAssertTrue(content.contains("0"))
            XCTAssertTrue(content.contains("1"))
            XCTAssertEqual(content.filter { $0 == "X" }.count, 2)
        }
    }
    
    func testWithComplexModifiers() {
        XCTContext.runActivity(named: "when ForEach<Text> And ForEach is contained ParentView. And ForEach has .border.border") { (_) in
            let view = VStack {
                ForEach((0..<2)) { element in
                    Text("\(element)")
                }
                .border(Color.blue)
                .border(Color.red)
            }
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter
            let elementCount = 2

            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertTrue(driver.storedForegroundColors.contains(.red))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), (1 * 4 * elementCount) * 2)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), (1 * 2 * elementCount) + (3 * 2 * elementCount))
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), (1 * 2 * elementCount) + (3 * 2 * elementCount))
            XCTAssertEqual(content.filter { $0 == "0" }.count, 1)
            XCTAssertEqual(content.filter { $0 == "1" }.count, 1)
        }
        XCTContext.runActivity(named: "when ForEach<TupleView<(Text, Text)>> And ForEach is contained ParentView. And ForEach has .border.border") { (_) in
            let view = VStack {
                ForEach((0..<2)) { element in
                    Text("\(element)")
                    Text("X")
                }
                .border(Color.blue)
                .border(Color.red)
            }
            
            let graph = prepareSizedGraph(view: view)
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            
            graph.accept(visitor: visitor)
            let content = driver.content()
            
            let subject: (String) -> Int = { (delimiter: String) in
                content.filter { String($0) == delimiter }.count
            }
            
            let cornerDelimiter = Edge.Set.leadingTop.defaultDelimiter
            let elementCount = 4
            
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertTrue(driver.storedForegroundColors.contains(.red))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
            XCTAssertEqual(subject(cornerDelimiter), (1 * 4 * elementCount) * 2)
            XCTAssertEqual(subject(Edge.Set.vertical.defaultDelimiter), (1 * 2 * elementCount) + (3 * 2 * elementCount))
            XCTAssertEqual(subject(Edge.Set.horizontal.defaultDelimiter), (1 * 2 * elementCount) + (3 * 2 * elementCount))
            XCTAssertEqual(content.filter { $0 == "0" }.count, 1)
            XCTAssertEqual(content.filter { $0 == "1" }.count, 1)
            XCTAssertEqual(content.filter { $0 == "X" }.count, 2)
        }
    }
}
