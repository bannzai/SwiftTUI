//
//  VStackTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/31.
//

import XCTest
@testable import SwiftTUI

class VStackTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
        sharedCursor = TestCursor()
    }
    
    var testSharedCursor: TestCursor { sharedCursor as! TestCursor }
    
    func testSize() {
        XCTContext.runActivity(named: "when VStack contains Text") { (_) in
            let view = VStack {
                Text("123")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.size, Size(width: "123".width, height: "123".height))
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("23")
                Text("456")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: "456".width, height: 3 + spacing))
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, ModifiedContent<Text, _AlignmentWritingModifier>> when .trailing alignment. And configure alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                Text("23")
                Text("456")
                    .alignmentGuide(.trailing, computeValue: { _ in return 1 })
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)

            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: 4, height: elementCount + spacing))
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<_AlignmentWritingModifier<Text>, Text, Text> when .leading alignment and specity negative value") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .alignmentGuide(.leading, computeValue: { _ in return -1 })
                Text(",")
                Text("World")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)

            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: 6, height: elementCount + spacing))
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<_PaddingLayout<Text>, Text, Text> when .leading alignment and specity negative value") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .padding(1)
                Text(",")
                Text("World")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: "Hello".width + defaultPadding * 2, height: elementCount + spacing + defaultPadding * 2))
        }
    }
}


// MARK: - Children Position
extension VStackTests {
    func testChildrenPositionWithoutModifier() {
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text> when .leading alignment") { (_) in
            let view = VStack(alignment: .leading) {
                Text("1")
                Text("23")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Text graph confirm to leading position") { (_) in
                first: do {
                    let textGraph = graph.children[0].children[0]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "1")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "23")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "1".height)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text(\"1\"), Text(\"23\"), Text(\"456\")> when .center alignment.") { (_) in
            let view = VStack(alignment: .center) {
                Text("1")
                Text("23")
                Text("456")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to trailing position") { (_) in
                first: do {
                    let textGraph = graph.children[0].children[0]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "1")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "23")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "1".height)
                }
                third: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "456")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace * 2 + "1".height + "23".height)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text(\"1\"), Text(\"23\"), Text(\"456\")> when .trailing alignment.") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                Text("23")
                Text("456")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to trailing position") { (_) in
                first: do {
                    let textGraph = graph.children[0].children[0]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "1")
                    XCTAssertEqual(textGraph.rect.origin.x, 2)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "23")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "1".height)
                }
                third: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "456")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace * 2 + "1".height + "23".height)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text(\"456\"), Text(\"23\"), Text(\"1\")> when .trailing alignment.") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("456")
                Text("23")
                Text("1")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to trailing position") { (_) in
                third: do {
                    let textGraph = graph.children[0].children[0]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "456")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "23")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "1".height)
                }
                first: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "1")
                    XCTAssertEqual(textGraph.rect.origin.x, 2)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace * 2 + "1".height + "23".height)
                }
            }
        }
    }
    func testChildrenPositionWithAlignmentGuide() {
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, ModifiedContent<Text, _AlignmentWritingModifier>> when .leading alignment. And configure alignmentGuide") { (_) in
            let view = VStack(alignment: .leading) {
                Text("1")
                Text("23")
                Text("456")
                    .alignmentGuide(.leading, computeValue: { _ in return 2 })
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to leading position") { (_) in
                first: do {
                    let textGraph = graph.children[0].children[0]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "1")
                    XCTAssertEqual(textGraph.rect.origin.x, 2)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "23")
                    XCTAssertEqual(textGraph.rect.origin.x, 2)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "1".height)
                }
                third: do {
                    let modifierGraph = graph.children[0].children[2]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _AlignmentWritingModifier)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "456")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace * 2 + "1".height + "23".height)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text(\"1\"), Text(\"23\"), ModifiedContent<Text(\"456\"), _AlignmentWritingModifier>> when .trailing alignment. And configure alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                Text("23")
                Text("456")
                    .alignmentGuide(.trailing, computeValue: { _ in return 2 })
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to trailing position") { (_) in
                first: do {
                    let textGraph = graph.children[0].children[0]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "1")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "23")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "1".height)
                }
                third: do {
                    let modifierGraph = graph.children[0].children[2]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _AlignmentWritingModifier)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "456")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace * 2 + "1".height + "23".height)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<ModifiedContent<Text(\"1\"), _AlignmentWritingModifier>, Text(\"23\"), Text(\"456\")> when .trailing alignment. And configure alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("456")
                    .alignmentGuide(.trailing, computeValue: { _ in return 2 })
                Text("23")
                Text("1")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to trailing position") { (_) in
                first: do {
                    let modifierGraph = graph.children[0].children[0]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _AlignmentWritingModifier)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "456")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.x, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "23")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "456".height)
                }
                third: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "1")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace * 2 + "456".height + "23".height)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<_AlignmentWritingModifier<Text>, Text, Text> when .leading alignment and specity negative value") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .alignmentGuide(.leading, computeValue: { _ in return -1 })
                Text(",")
                Text("World")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Text graph confirm to leading position") { (_) in
                first: do {
                    let modifierGraph = graph.children[0].children[0]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _AlignmentWritingModifier)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "Hello")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, ",")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height)
                }
                third: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "World")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height + ",".height)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<_AlignmentWritingModifier<Text>, Text, _AlignmentWritingModifier<Text>> when .leading alignment and specity two negative value") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .alignmentGuide(.leading, computeValue: { _ in return -1 })
                Text(",")
                Text("World")
                    .alignmentGuide(.leading, computeValue: { _ in return -2 })
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Text graph confirm to leading position") { (_) in
                first: do {
                    let modifierGraph = graph.children[0].children[0]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _AlignmentWritingModifier)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "Hello")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, ",")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height)
                }
                third: do {
                    let modifierGraph = graph.children[0].children[2]
                    
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _AlignmentWritingModifier)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "World")
                    XCTAssertEqual(textGraph.rect.origin.x, 2)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height + ",".height)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<_AlignmentWritingModifier<Text>, Text, Text> when .leading alignment and specity leading alignment value") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .alignmentGuide(.leading, computeValue: { _ in return 1 })
                Text(",")
                Text("World")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Text graph confirm to leading position") { (_) in
                first: do {
                    let modifierGraph = graph.children[0].children[0]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _AlignmentWritingModifier)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "Hello")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.x, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, ",")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height)
                }
                third: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "World")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height + ",".height)
                }
            }
        }
    }
    func testChildrenPositionWithFrameLayout() {
        XCTContext.runActivity(named: "when VStack contains TupleView<_PaddingLayout<Text>, Text, Text> and specify leading alignment") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .frame(width: 10, height: 3)
                Text(",")
                Text("World")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to trailing position") { (_) in
                first: do {
                    let modifierGraph = graph.children[0].children[0]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _FrameLayout)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "Hello")
                    XCTAssertEqual(textGraph.rect.origin.x, 3)
                    XCTAssertEqual(textGraph.rect.origin.y, 1)
                    XCTAssertEqual(modifierGraph.rect.origin.x, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, ",")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height + defaultPadding * 2)
                }
                third: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "World")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height + ",".height + defaultPadding * 2)
                }
            }
        }
    }
    func testChildrenPositionWithPaddingLayout() {
        XCTContext.runActivity(named: "when VStack contains TupleView<_PaddingLayout<Text>, Text, Text> and specify leading alignment") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .padding(1)
                Text(",")
                Text("World")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to trailing position") { (_) in
                first: do {
                    let modifierGraph = graph.children[0].children[0]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _PaddingLayout)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "Hello")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, 1)
                    XCTAssertEqual(modifierGraph.rect.origin.x, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, ",")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height + defaultPadding * 2)
                }
                third: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "World")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height + ",".height + defaultPadding * 2)
                }
            }
        }
    }
    
    func testChildrenPositionForComplexPattern() {
        XCTContext.runActivity(named: "VStack<TupleView<Text, VStack<Text>>") { _ in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                VStack(alignment: .trailing) {
                    Text("World")
                }
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm position") { (_) in
                first: do {
                    let textGraph = graph.children[0].children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "Hello")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let vstackGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(vstackGraph.anyView is VStack<Text>)
                    XCTAssertEqual(vstackGraph.rect.origin.x, 0)
                    XCTAssertEqual(vstackGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height)
                    
                    children: do {
                        let textGraph = vstackGraph.children[0]
                        XCTAssertTrue(textGraph.anyView is Text)
                        let text = textGraph.anyView as! Text
                        
                        XCTAssertEqual(text.content, "World")
                        XCTAssertEqual(textGraph.rect.origin.x, 0)
                        XCTAssertEqual(textGraph.rect.origin.y, 0)
                    }
                }
            }
        }
        XCTContext.runActivity(named: "VStack<TupleView<Text, VStack<TupleView<Text, Text>>>") { _ in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                VStack(alignment: .trailing) {
                    Text(",")
                    Text("World")
                }
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm position") { (_) in
                first: do {
                    let textGraph = graph.children[0].children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "Hello")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let vstackGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(vstackGraph.anyView is VStack<TupleView<(Text, Text)>>)
                    XCTAssertEqual(vstackGraph.rect.origin.x, 0)
                    XCTAssertEqual(vstackGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height)
                    
                    children: do {
                        do {
                            let textGraph = vstackGraph.children[0].children[0]
                            XCTAssertTrue(textGraph.anyView is Text)
                            let text = textGraph.anyView as! Text
                            
                            XCTAssertEqual(text.content, ",")
                            XCTAssertEqual(textGraph.rect.origin.x, 4)
                            XCTAssertEqual(textGraph.rect.origin.y, 0)
                        }
                        do {
                            let textGraph = vstackGraph.children[0].children[1]
                            XCTAssertTrue(textGraph.anyView is Text)
                            let text = textGraph.anyView as! Text
                            
                            XCTAssertEqual(text.content, "World")
                            XCTAssertEqual(textGraph.rect.origin.x, 0)
                            XCTAssertEqual(textGraph.rect.origin.y, 1)
                        }
                    }
                }
            }
        }
    }
    
    func testChildrenPositionWithBorderModifier() {
        XCTContext.runActivity(named: "when VStack contains TupleView<_BorderModifier<Text>, Text, Text> and specify leading alignment") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .border(.blue)
                Text(",")
                Text("World")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to trailing position") { (_) in
                first: do {
                    let modifierGraph = graph.children[0].children[0]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _BorderModifier)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "Hello")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, 1)
                    XCTAssertEqual(modifierGraph.rect.origin.x, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, ",")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height + defaultPadding * 2)
                }
                third: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "World")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace + "Hello".height + ",".height + defaultPadding * 2)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, ModifiedContent<ModifiedContent<Text, _BackgroundModifier> _BackgroundModifier>, Text> and alignment with leading") { (_) in
            let view = VStack(alignment: .leading) {
                Text("Hello")
                    .border(.red)
                    .border(.blue)
                Text(",")
                Text("World")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Child graph confirm to trailing position") { (_) in
                first: do {
                    let blueBorderGraph = graph.children[0].children[0]
                    let blueBorderModifier = blueBorderGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(blueBorderModifier.anyModifier is _BorderModifier)
                    
                    let redBorderGraph = blueBorderGraph.children[0]
                    let redBorderModifier = redBorderGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(redBorderModifier.anyModifier is _BorderModifier)
                    
                    let textGraph = redBorderGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "Hello")
                    XCTAssertEqual(textGraph.rect.origin.x, 1)
                    XCTAssertEqual(textGraph.rect.origin.y, 1)
                    XCTAssertEqual(redBorderGraph.rect.origin.x, 1)
                    XCTAssertEqual(redBorderGraph.rect.origin.y, 1)
                    XCTAssertEqual(blueBorderGraph.rect.origin.x, 0)
                    XCTAssertEqual(blueBorderGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, ",")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 5)
                }
                third: do {
                    let textGraph = graph.children[0].children[2]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "World")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 6)
                }
            }
        }
    }
}

// MARK: - Children Content

extension VStackTests {
    func testChildrenContent() {
        XCTContext.runActivity(named: "when VStack(alignment: .trailing) contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                Text("23")
                Text("456")
            }
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertTrue(result.contains("1"))
            XCTAssertTrue(result.contains("23"))
            XCTAssertTrue(result.contains("456"))
            XCTAssertAmbiguouseOrder(testSharedCursor.xHistory, [2, 1, 0])
            XCTAssertAmbiguouseOrder(testSharedCursor.yHistory, [0, ViewVisitorListOption.vertical.defaultSpace + "1".height, ViewVisitorListOption.vertical.defaultSpace + "1".height + "23".height])
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
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            let result = driver.content()
            
            XCTAssertTrue(result.contains("Hello"))
            XCTAssertTrue(result.contains(","))
            XCTAssertTrue(result.contains("World"))
            XCTAssertAmbiguouseOrder(testSharedCursor.xHistory, [3, 4, 0])
            XCTAssertAmbiguouseOrder(testSharedCursor.yHistory, [0, ViewVisitorListOption.vertical.defaultSpace + "Hello".height, ViewVisitorListOption.vertical.defaultSpace + "Hello".height + ",".height])
            
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
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            
            let result = driver.content()
            
            XCTAssertEqual(driver.storedString, "Hello,World")
            XCTAssertTrue(result.contains("Hello"))
            XCTAssertTrue(result.contains(","))
            XCTAssertTrue(result.contains("World"))
            XCTAssertAmbiguouseOrder(testSharedCursor.xHistory, [1, 0, 0])
            XCTAssertAmbiguouseOrder(testSharedCursor.yHistory, [0, ViewVisitorListOption.vertical.defaultSpace + "Hello".height, ViewVisitorListOption.vertical.defaultSpace + "Hello".height + ",".height])
            
            XCTAssertEqual(graph.rect.size.width, 6)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, ModfiiedContent<Text, _FrameLayout>> when .leading alignment and specity value small than text content") { (_) in
            let view = VStack(alignment: .leading) {
                    Text("Hello")
                    Text(",")
                    Text("World")
                        .frame(width: 4, height: 3)
            }

            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            let graph = prepareSizedGraph(view: view)
            visitor.visit(graph)
            
            XCTAssertEqual(driver.storedString, "Hello,Worl")
            XCTAssertAmbiguouseOrder(testSharedCursor.xHistory, [0, 0, 0])
            XCTAssertAmbiguouseOrder(testSharedCursor.yHistory, [0, ViewVisitorListOption.vertical.defaultSpace + "Hello".height, ViewVisitorListOption.vertical.defaultSpace + "Hello".height + ",".height])
            
            XCTAssertEqual(graph.rect.size.width, 5)
            XCTAssertEqual(graph.rect.size.height, 5)
        }
    }
}
