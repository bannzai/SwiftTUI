//
//  ViewAlignmentVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/10.
//

import XCTest
@testable import SwiftTUI

class ViewDimensionsVisitorTests: XCTestCase {
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

    func testVisit() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.children.count, 0)
            
            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(graph)

            XCTAssertEqual(dimensions.width, "hoge".width)
            XCTAssertEqual(dimensions.height, 1)
            XCTAssertEqual(dimensions[HorizontalAlignment.default], "hoge".width / 2)
            XCTAssertEqual(dimensions[VerticalAlignment.default], 0)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(dimensions[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when Text with content with linebreak") { (_) in
            let view = Text("hoge\nfuga")

            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.children.count, 0)
            
            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(graph)
            
            XCTAssertEqual(dimensions.width, "hoge".width)
            XCTAssertEqual(dimensions.height, 2)
            XCTAssertEqual(dimensions[HorizontalAlignment.default], "hoge".width / 2)
            XCTAssertEqual(dimensions[VerticalAlignment.default], 1)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(dimensions[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when TupleView<Text, Text, Text>") { (_) in
            let view = TupleView((
                Text("1"),
                Text("23"),
                Text("456")
            ))
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            graph.listType = .vertical
            XCTAssertEqual(graph.children.count, 3)

            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(graph)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(dimensions.width, "456".width)
            XCTAssertEqual(dimensions.height, elementCount + spacing)
            XCTAssertEqual(dimensions[HorizontalAlignment.default], "456".width / 2)
            XCTAssertEqual(dimensions[VerticalAlignment.default], (elementCount + spacing) / 2)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(dimensions[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("23")
                Text("456")
            }
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertEqual(graph.children[0].children.count, 3)

            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(graph)
            
            let elementCount = 3
            let spacing = (elementCount - 1) * ViewVisitorListOption.vertical.defaultSpace
            
            XCTAssertEqual(dimensions.width, "456".width)
            XCTAssertEqual(dimensions.height, elementCount + spacing)
            XCTAssertEqual(dimensions[HorizontalAlignment.default], "456".width / 2)
            XCTAssertEqual(dimensions[VerticalAlignment.default], (elementCount + spacing) / 2)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
            XCTAssertNil(dimensions[explicit: VerticalAlignment.default])
        }
        XCTContext.runActivity(named: "when Text with alignmentGuide") { (_) in
            let view = Text("hoge").alignmentGuide(.bottom) { _ in 20000 }

            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertEqual(graph.children[0].children.count, 0)

            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(graph)
            
            XCTAssertNil(dimensions[explicit: .bottom])
        }
    }
    
    func testVisit_withAlignmentGuide() {
        XCTContext.runActivity(named: "when Text with alignmentGuide") { (_) in
            let view = Text("hoge").alignmentGuide(.bottom) { _ in 20000 }

            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertEqual(graph.children[0].children.count, 0)
            
            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(graph)
            
            XCTAssertNil(dimensions[explicit: .bottom])
        }
        XCTContext.runActivity(named: "when VStack<TupleView<(Text, Text, Text)>> with first Text has alignmentGuide. But VStack using .default(.leading) horizontal alignment") { (_) in
            let view = VStack {
                Text("1")
                    .alignmentGuide(.trailing) { _ in 200000 }
                Text("23")
                Text("456")
            }


            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertEqual(graph.children[0].children.count, 3)

            XCTAssertEqual(graph.alignment.horizontal, .default)
            
            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ModifiedContent<Text, _AlignmentWritingModifier>})!
            XCTAssertEqual(firstModifier.children.count, 1)
            XCTAssertTrue(firstModifier.anyView is ModifiedContent<Text, _AlignmentWritingModifier>)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(firstModifier)
            
            XCTAssertNil(dimensions[explicit: .trailing])
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
        }
        XCTContext.runActivity(named: "when VStack<TupleView<(Text, Text, Text)>> with first Text has alignmentGuide and VStack using same (.trailing) horizontal alignment") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                    .alignmentGuide(.trailing) { _ in 200000 }
                Text("23")
                Text("456")
            }
            
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.alignment.horizontal, .trailing)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertEqual(graph.children[0].children.count, 3)

            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ModifiedContent<Text, _AlignmentWritingModifier>})!
            XCTAssertEqual(firstModifier.children.count, 1)
            XCTAssertTrue(firstModifier.anyView is ModifiedContent<Text, _AlignmentWritingModifier>)

            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(firstModifier)
            
            XCTAssertEqual(dimensions[explicit: .trailing], 200000)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
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
            
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.alignment.horizontal, .trailing)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertEqual(graph.children[0].children.count, 3)
            
            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            typealias ViewType = ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ViewType })!
            XCTAssertEqual(firstModifier.children.count, 1)
            XCTAssertTrue(firstModifier.anyView is ViewType)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(firstModifier)
            
            XCTAssertEqual(dimensions[explicit: .trailing], 200)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
        }

        XCTContext.runActivity(named: "when VStack<TupleView<(Text, Text, Text)>> with first Text has alignmentGuide and VStack using not same horizontal alignment referenced child explicit alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                    .alignmentGuide(.top) { dimensions in
                        200
                }
                .alignmentGuide(.trailing) { dimensions in
                    dimensions[explicit: .top] ?? 100
                }
                Text("23")
                Text("456")
            }
            
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertEqual(graph.children[0].children.count, 3)
            XCTAssertEqual(graph.alignment.horizontal, .trailing)
            
            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            typealias ViewType = ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ViewType })!
            XCTAssertEqual(firstModifier.children.count, 1)
            XCTAssertTrue(firstModifier.anyView is ViewType)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(firstModifier)
            
            XCTAssertEqual(dimensions[explicit: .trailing], 200)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
        }
        XCTContext.runActivity(named: "when VStack<TupleView<(Text, Text, Text)>> with first Text has alignmentGuide and VStack using same (.trailing) horizontal alignment referenced double child explicit alignmentGuide") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                    .alignmentGuide(.trailing) { dimensions in
                        dimensions[explicit: .trailing] ?? 200
                }
                .alignmentGuide(.trailing) { dimensions in
                    dimensions[explicit: .trailing] ?? 100
                }
                .alignmentGuide(.trailing) { dimensions in
                    dimensions[explicit: .trailing] ?? 50
                }
                Text("23")
                Text("456")
            }
            
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertEqual(graph.children[0].children.count, 3)
            XCTAssertEqual(graph.alignment.horizontal, .trailing)
            
            // FIXME: Remove Size Visitor??
            let sizeVisitor = ViewSizeVisitor()
            _ = sizeVisitor.visit(graph)
            
            typealias ViewType = ModifiedContent<ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>, _AlignmentWritingModifier>
            let firstModifier = graph.children.first!.children.first(where: { $0.anyView is ViewType })!
            XCTAssertEqual(firstModifier.children.count, 1)
            XCTAssertTrue(firstModifier.anyView is ViewType)
            
            let visitor = ViewDimensionsVisitor()
            let dimensions = visitor.visit(firstModifier)
            
            XCTAssertEqual(dimensions[explicit: .trailing], 200)
            XCTAssertNil(dimensions[explicit: HorizontalAlignment.default])
        }
    }
    
    // NOTE: Method for playground test
    func test_playground() {
        XCTContext.runActivity(named: "Playground for child count") { (_) in
            let view = VStack(alignment: .trailing) {
                Text("1")
                    .alignmentGuide(.leading, computeValue: { _ in 10 })
                Text("23")
                Text("456")
            }
            
            
            let graphVisitor = ViewGraphSetVisitor()
            let graph = graphVisitor.visit(view: view)
            
            XCTAssertEqual(graph.alignment.horizontal, .trailing)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertEqual(graph.children[0].children.count, 3)
        }
    }
}
