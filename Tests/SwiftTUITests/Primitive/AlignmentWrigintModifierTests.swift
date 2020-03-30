//
//  AlignmentWrigintModifierTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/03/31.
//

import XCTest
@testable import SwiftTUI

class AlignmentWrigintModifierTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }

    func testWrigintExplicit() {
        func prepare<T: View>(view: T, viewListOption: ViewVisitorListOption = .vertical) -> ViewGraph {
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view)
            graph.listType = viewListOption
            
            return graph
        }
        XCTContext.runActivity(named: "when Text with alignmentGuide") { (_) in
            let view = Text("hoge").alignmentGuide(.bottom) { _ in 20000 }
            
            let graph = prepare(view: view)
            let visitor = ViewSetRectVisitor()
            graph.accept(visitor: visitor)

            XCTAssertNil(graph.dimensions[explicit: .bottom])
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
            graph.accept(visitor: visitor)
            
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ModifiedContent<Text, _AlignmentWritingModifier>})!
            XCTAssertTrue(firstModifier.anyView is ModifiedContent<Text, _AlignmentWritingModifier>)
            
            XCTAssertEqual(firstModifier.dimensions[explicit: .trailing], 200000)
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
            graph.accept(visitor: visitor)

            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ModifiedContent<Text, _AlignmentWritingModifier>})!
            XCTAssertEqual(firstModifier.dimensions[explicit: .trailing], 200000)
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
            graph.accept(visitor: visitor)

            typealias ViewType = ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ViewType })!
            XCTAssertEqual(firstModifier.dimensions[explicit: .trailing], 200)
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

            typealias ViewType = ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ViewType })!
            XCTAssertEqual(firstModifier.dimensions[explicit: .trailing], 200)
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
            graph.accept(visitor: visitor)

            typealias ViewType = ModifiedContent<ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>, _AlignmentWritingModifier>
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ViewType })!
            XCTAssertEqual(firstModifier.dimensions[explicit: .trailing], 202)
        }
    }
}
