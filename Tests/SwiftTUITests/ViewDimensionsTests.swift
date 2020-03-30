//
//  ViewAlignmentVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/10.
//

import XCTest
@testable import SwiftTUI

class ViewDimensionsTests: XCTestCase {
    private func prepare<T: View>(view: T, viewListOption: ViewVisitorListOption = .vertical) -> ViewGraph {
        let graphVisitor = ViewGraphSetVisitor()
        let graph = graphVisitor.visit(view)
        graph.listType = viewListOption
        
        return graph
    }

    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }

    func testVisit() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)

            XCTAssertNil(visitor.currentDimensions?[explicit: HorizontalAlignment.default])
            XCTAssertNil(visitor.currentDimensions?[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when Text with content with linebreak") { (_) in
            let view = Text("hoge\nfuga")

            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)

            XCTAssertNil(visitor.currentDimensions?[explicit: HorizontalAlignment.default])
            XCTAssertNil(visitor.currentDimensions?[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when TupleView<Text, Text, Text>") { (_) in
            let view = TupleView((
                Text("1"),
                Text("23"),
                Text("456")
            ))
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)

            XCTAssertNil(visitor.currentDimensions?[explicit: HorizontalAlignment.default])
            XCTAssertNil(visitor.currentDimensions?[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("23")
                Text("456")
            }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)

            XCTAssertNil(visitor.currentDimensions?[explicit: HorizontalAlignment.default])
            XCTAssertNil(visitor.currentDimensions?[explicit: VerticalAlignment.default])
        }
    }
    
    func testVisit_withAlignmentGuide() {
        XCTContext.runActivity(named: "when Text with alignmentGuide") { (_) in
            let view = Text("hoge").alignmentGuide(.bottom) { _ in 20000 }

            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)

            XCTAssertNil(visitor.currentDimensions?[explicit: .bottom])
        }
        XCTContext.runActivity(named: "when VStack<TupleView<(Text, Text, Text)>> with first Text has alignmentGuide. But VStack using .default(.leading) horizontal alignment") { (_) in
            let view = VStack {
                Text("1")
                    .alignmentGuide(.trailing) { _ in 200000 }
                Text("23")
                Text("456")
            }

            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)

            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ModifiedContent<Text, _AlignmentWritingModifier>})!
            XCTAssertTrue(firstModifier.anyView is ModifiedContent<Text, _AlignmentWritingModifier>)
            
            XCTAssertEqual(visitor.currentDimensions?[explicit: .trailing], 200000)
        }
        XCTContext.runActivity(named: "when VStack<TupleView<(Text, Text, Text)>> with first Text has alignmentGuide and VStack using same (.trailing) horizontal alignment") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                    .alignmentGuide(.trailing) { _ in 200000 }
                Text("23")
                Text("456")
            }

            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)

            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ModifiedContent<Text, _AlignmentWritingModifier>})!
            XCTAssertTrue(firstModifier.anyView is ModifiedContent<Text, _AlignmentWritingModifier>)

            XCTAssertEqual(visitor.currentDimensions?[explicit: .trailing], 200000)
        }
        
        XCTContext.runActivity(named: "when VStack<TupleView<(Text, Text, Text)>> with first Text has alignmentGuide and VStack using same (.trailing) horizontal alignment referenced child explicit alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                    .alignmentGuide(.trailing) { dimensions in
                        dimensions[explicit: .trailing] ?? 200
                }
                .alignmentGuide(.trailing) { dimensions in
                    dimensions[explicit: .trailing] ?? 100
                }
                Text("23")
                Text("456")
            }

            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)

            typealias ViewType = ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ViewType })!
            XCTAssertTrue(firstModifier.anyView is ViewType)
            
            XCTAssertEqual(visitor.currentDimensions?[explicit: .trailing], 200)
        }

        XCTContext.runActivity(named: "when VStack<TupleView<(Text, Text, Text)>> with first Text has alignmentGuide and VStack using not same horizontal alignment referenced child explicit alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                    .alignmentGuide(.top) { dimensions in 200 }
                    .alignmentGuide(.trailing) { dimensions in dimensions[explicit: .top] ?? 100 }
                Text("23")
                Text("456")
            }

            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)

            XCTAssertEqual(graph.alignment.horizontal, .trailing)

            typealias ViewType = ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ViewType })!
            XCTAssertTrue(firstModifier.anyView is ViewType)

            XCTAssertEqual(visitor.currentDimensions?[explicit: .trailing], 200)
        }
        XCTContext.runActivity(named: "when VStack<TupleView<(Text, Text, Text)>> with first Text has alignmentGuide and VStack using same (.trailing) horizontal alignment referenced double child explicit alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                    .alignmentGuide(.trailing) { dimensions in 200 }
                    .alignmentGuide(.trailing) { dimensions in dimensions[explicit: .trailing]! + 1 }
                    .alignmentGuide(.trailing) { dimensions in dimensions[explicit: .trailing]! + 1 }
                Text("23")
                Text("456")
            }

            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            visitor.visit(graph)

            typealias ViewType = ModifiedContent<ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>, _AlignmentWritingModifier>
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ViewType })!
            XCTAssertTrue(firstModifier.anyView is ViewType)
            
            XCTAssertEqual(visitor.currentDimensions?[explicit: .trailing], 202)
        }
    }
}
