//
//  ViewContainerContentSizeVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/22.
//

import XCTest
@testable import SwiftTUI

class ViewContainerContentSizeVisitorTests: XCTestCase {
    struct CustomView<Target: View>: View {
        let body: Target
    }
    class DummyScreen: Screen {
        override var columns: PhysicalDistance { 100 }
        override var rows: PhysicalDistance { 100 }
    }
    private func prepare<T: View>(view: T, viewListOption: ViewVisitorListOption = .vertical) -> ViewGraph {
        let graphVisitor = ViewGraphSetVisitor()
        let graph = graphVisitor.visit(view)
        graph.listType = viewListOption
        
        // FIXME: Remove Size Visitor??
        let sizeVisitor = ViewIntrinsicContentSizeVisitor()
        _ = sizeVisitor.visit(graph)
        graph.accept_position(visitor: sizeVisitor)

        return graph
    }
    
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    func testAccept() {
        XCTContext.runActivity(named: "when CustomView has VStack<Text>") { (_) in
            let view = CustomView(body: VStack { Text("123") })
            
            let graph = prepare(view: view)
            graph.accept_container(visitor: ViewContainerContentSizeVisitor())

            XCTAssertEqual(graph.rect.size, Size(width: "123".width, height: 1))
        }
        XCTContext.runActivity(named: "when CustomView has VStack<TupleView<CustomView<Text>, CustomView<Text>>>") { (_) in
            let view = CustomView(body: VStack {
                CustomView(body: Text("123"))
                CustomView(body: Text("456"))
            })
            
            let graph = prepare(view: view)
            graph.accept_container(visitor: ViewContainerContentSizeVisitor())

            let elementCount = 2
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: "456".width, height: 2 + spacing))
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("23")
                Text("456")
            }
            
            let graph = prepare(view: view)
            graph.accept_container(visitor: ViewContainerContentSizeVisitor())

            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: "456".width, height: 3 + spacing))
        }
        XCTContext.runActivity(named: "when CustomView has VStack<TupleView<Text, Text, Text>>") { (_) in
            let view = CustomView(body: VStack {
                Text("123")
                Text("456")
                Text("789")
            })
            
            let graph = prepare(view: view)
            graph.accept_container(visitor: ViewContainerContentSizeVisitor())

            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: "456".width, height: 3 + spacing))
        }
        XCTContext.runActivity(named: "when TupleView<Text, Text, Text>") { (_) in
            let view = TupleView((
                Text("1"),
                Text("23"),
                Text("456")
            ))
            
            let graph = prepare(view: view)
            graph.accept_container(visitor: ViewContainerContentSizeVisitor())
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: "456".width, height: elementCount + spacing))
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, ModifiedContent<Text, _AlignmentWritingModifier>> when .trailing alignment. And configure alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                Text("23")
                Text("456")
                    .alignmentGuide(.trailing, computeValue: { _ in return 1 })
            }
            
            let graph = prepare(view: view)
            graph.accept_container(visitor: ViewContainerContentSizeVisitor())
            
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
            graph.accept_container(visitor: ViewContainerContentSizeVisitor())
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(graph.rect.size, Size(width: 6, height: elementCount + spacing))
        }
    }
}
