//
//  ViewOriginVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/18.
//

import XCTest
@testable import SwiftTUI

class ViewPositionSetVisitorTests: XCTestCase {
    struct CustomView<Target: View>: View {
        let body: Target
    }
    class DummyScreen: Screen {
        override var columns: PhysicalDistance { 100 }
        override var rows: PhysicalDistance { 100 }
    }
    
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    private func prepare<T: View>(view: T, viewListOption: ViewVisitorListOption = .vertical) -> ViewGraph {
        let graphVisitor = ViewGraphSetVisitor()
        let graph = graphVisitor.visit(view)
        graph.listType = viewListOption
        
        // FIXME: Remove Size Visitor??
        let sizeVisitor = ViewIntrinsicContentSizeVisitor()
        _ = sizeVisitor.visit(graph)
        
        let dimensionsVisitor = ViewDimensionsVisitor()
        _ = dimensionsVisitor.visit(graph)
        
        return graph
    }
    
    
    func test_playground() {
        XCTContext.runActivity(named: "when VStack contains TupleView<_AlignmentWritingModifier<Text>, Text, Text> when .trailing alignment") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("Hello")
                    .alignmentGuide(.trailing, computeValue: { _ in return 2 })
                Text(",")
                Text("World")
            }

            let graph = prepare(view: view)
            let visitor = ViewPositionSetVisitor()
            visitor.visit(graph)
            
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
                    XCTAssertEqual(modifierGraph.rect.origin.x, 3)
                    XCTAssertEqual(modifierGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children[0].children[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, ",")
                    XCTAssertEqual(textGraph.rect.origin.x, 4)
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
    }

    func testAccept() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let graph = prepare(view: view)
            
            let visitor = ViewPositionSetVisitor()
            visitor.visit(graph)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text> when .leading alignment") { (_) in
            let view = VStack(alignment: .leading) {
                Text("1")
                Text("23")
            }
            
            let graph = prepare(view: view)
            
            let visitor = ViewPositionSetVisitor()
            visitor.visit(graph)

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
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, ModifiedContent<Text, _AlignmentWritingModifier>> when .leading alignment. And configure alignmentGuide") { (_) in
            let view = VStack(alignment: .leading) {
                Text("1")
                Text("23")
                Text("456")
                    .alignmentGuide(.leading, computeValue: { _ in return 2 })
            }
            
            let graph = prepare(view: view)
            let visitor = ViewPositionSetVisitor()
            visitor.visit(graph)
            
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
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.x, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace * 2 + "1".height + "23".height)
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
            let visitor = ViewPositionSetVisitor()
            visitor.visit(graph)
            
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
        XCTContext.runActivity(named: "when VStack contains TupleView<Text(\"1\"), Text(\"23\"), ModifiedContent<Text(\"456\"), _AlignmentWritingModifier>> when .trailing alignment. And configure alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                Text("23")
                Text("456")
                    .alignmentGuide(.trailing, computeValue: { _ in return 2 })
            }
            
            let graph = prepare(view: view)
            let visitor = ViewPositionSetVisitor()
            visitor.visit(graph)
            
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
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.x, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.y, ViewVisitorListOption.default.defaultSpace * 2 + "1".height + "23".height)
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
            let visitor = ViewPositionSetVisitor()
            visitor.visit(graph)
            
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
        XCTContext.runActivity(named: "when VStack contains TupleView<ModifiedContent<Text(\"1\"), _AlignmentWritingModifier>, Text(\"23\"), Text(\"456\")> when .trailing alignment. And configure alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("456")
                    .alignmentGuide(.trailing, computeValue: { _ in return 2 })
                Text("23")
                Text("1")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewPositionSetVisitor()
            visitor.visit(graph)
            
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
    }
}
