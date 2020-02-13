//
//  ViewOriginVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/18.
//

import XCTest
@testable import SwiftTUI

class ViewPositionVisitorTests: XCTestCase {
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
        let graph = graphVisitor.visit(view: view)
        graph.listType = viewListOption
        
        // FIXME: Remove Size Visitor??
        let sizeVisitor = ViewSizeVisitor()
        _ = sizeVisitor.visit(graph)
        
        let dimensionsVisitor = ViewDimensionsVisitor()
        _ = dimensionsVisitor.visit(graph)
        
        return graph
    }
    
    func testExtract() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            XCTAssertEqual(position.x, "hoge".width / 2)
            XCTAssertEqual(position.y, 0)
        }
        XCTContext.runActivity(named: "when Text with content with linebreak") { (_) in
            let view = Text("hoge\nfuga")
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            XCTAssertEqual(position.x, "hoge".width / 2)
            XCTAssertEqual(position.y, 1)
        }
        XCTContext.runActivity(named: "when TupleView<Text, Text, Text>") { (_) in
            let view = TupleView((
                Text("1"),
                Text("23"),
                Text("456")
            ))
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            let height = elementCount + spacing
            
            XCTAssertEqual(position.x, "456".width / 2)
            XCTAssertEqual(position.y, height / 2)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("23")
                Text("456")
            }
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            let height = elementCount + spacing
            
            XCTAssertEqual(position.x, "456".width / 2)
            XCTAssertEqual(position.y, height / 2)
        }
        XCTContext.runActivity(named: "when CustomView has Text") { (_) in
            let view = CustomView(body: Text("123"))
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)

            XCTAssertEqual(position.x, "123".width / 2)
            XCTAssertEqual(position.y, 0)
        }
        XCTContext.runActivity(named: "when CustomView has VStack<TupleView<Text, Text, Text>>") { (_) in
            let view = CustomView(body: VStack {
                Text("123")
                Text("456")
                Text("789")
            })
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            let height = elementCount + spacing
            
            XCTAssertEqual(position.x, "456".width / 2)
            XCTAssertEqual(position.y, height / 2)
        }
        XCTContext.runActivity(named: "when Text with Modifier for _BackgroundModifier<Text>. _BackgroundModifier is not modifed size") { (_) in
            let view = Text("123").background(Color.red)
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            XCTAssertEqual(position.x, "123".width / 2)
            XCTAssertEqual(position.y, 0)
        }
        XCTContext.runActivity(named: "when Original Modifier") { (_) in
            struct Modifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.background(Color.red)
                }
            }
            
            let view = Text("1").modifier(Modifier())
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = graph.extract(visitor: visitor)
            
            XCTAssertEqual(position.x, "1".width / 2)
            XCTAssertEqual(position.y, 0)
        }
    }
    
    func testAccept() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = visitor.visit(graph)
            
            XCTAssertEqual(position.x, 0)
            XCTAssertEqual(position.y, 0)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text> when .leading alignment") { (_) in
            let view = VStack(alignment: .leading) {
                Text("1")
                Text("23")
            }
            
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = visitor.visit(graph)
            
            XCTAssertEqual(position.x, 0)
            XCTAssertEqual(position.y, 0)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Text graph confirm to leading position") { (_) in
                first: do {
                    let textGraph = graph.children.map { $0 }[0].children.map { $0 }[0]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "1")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children.map { $0 }[0].children.map { $0 }[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "23")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 3)
                }
            }
        }
    }
    
    func testX() {
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text> when .leading alignment. And configure alignmentGuide") { (_) in
            let view = VStack(alignment: .leading) {
                Text("1")
                Text("23")
                Text("456")
                    .alignmentGuide(.leading, computeValue: { _ in return 2 })
            }
            
            let graph = prepare(view: view)
            
            let visitor = ViewPositionVisitor()
            let position = visitor.visit(graph)
            
            XCTAssertEqual(position.x, 0)
            XCTAssertEqual(position.y, 0)
            
            XCTAssertEqual(graph.rect.origin.x, 0)
            XCTAssertEqual(graph.rect.origin.y, 0)
            
            XCTContext.runActivity(named: "Text graph confirm to center position") { (_) in
                first: do {
                    let textGraph = graph.children.map { $0 }[0].children.map { $0 }[0]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "1")
                    XCTAssertEqual(textGraph.rect.origin.x, 2)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                }
                second: do {
                    let textGraph = graph.children.map { $0 }[0].children.map { $0 }[1]
                    
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "23")
                    XCTAssertEqual(textGraph.rect.origin.x, 2)
                    XCTAssertEqual(textGraph.rect.origin.y, 3)
                }
                third: do {
                    let modifierGraph = graph.children.map { $0 }[0].children.map { $0 }[2]
                    let hasModifier = modifierGraph.anyView as! HasAnyModifier
                    XCTAssertTrue(hasModifier.anyModifier is _AlignmentWritingModifier)
                    
                    let textGraph = modifierGraph.children[0]
                    XCTAssertTrue(textGraph.anyView is Text)
                    let text = textGraph.anyView as! Text
                    
                    XCTAssertEqual(text.content, "456")
                    XCTAssertEqual(textGraph.rect.origin.x, 0)
                    XCTAssertEqual(textGraph.rect.origin.y, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.x, 0)
                    XCTAssertEqual(modifierGraph.rect.origin.y, 5)
                }
            }
        }
    }
}
