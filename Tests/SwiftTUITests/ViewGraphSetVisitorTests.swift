//
//  ViewGraphSetVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/06.
//

import XCTest
@testable import SwiftTUI

class ViewGraphSetVisitorTests: XCTestCase {

    struct CustomView<Target: View>: View {
        let body: Target
    }
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVisit() {
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("123")
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is Text)
            XCTAssertTrue(graph.children.isEmpty)
            XCTAssertTrue(graph.isRoot)
            XCTAssertFalse(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
        }
        XCTContext.runActivity(named: "when TupleView<Text, Text, Text>") { (_) in
            let view = TupleView((
                Text("1"),
                Text("23"),
                Text("456")
            ))
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is TupleView<(Text, Text, Text)>)
            XCTAssertEqual(graph.children.count, 3)
            XCTAssertTrue(graph.isRoot)
            XCTAssertFalse(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
            
            XCTContext.runActivity(named: "And check children view") { (_) in
                graph.children.forEach { child in
                    XCTAssertTrue(child.anyView is Text)
                    XCTAssertTrue(child.children.isEmpty)
                    XCTAssertFalse(child.isRoot)
                    XCTAssertFalse(child.isUserDefinedView)
                    XCTAssertFalse(child.isModifiedContent)
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let horizontalAlignment: HorizontalAlignment = .leading
            let spacing: PhysicalDistance = PhysicalDistance(100)
            let view = VStack(alignment: horizontalAlignment, spacing: spacing) {
                Text("1")
                Text("23")
                Text("456")
            }
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is VStack<TupleView<(Text, Text, Text)>>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertFalse(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
            
            XCTAssertEqual(graph.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
            XCTAssertEqual(graph.listType, .vertical)
            XCTAssertEqual(graph.spacing, spacing)
            
            XCTContext.runActivity(named: "And check children view of TupleView<(Text, Text, Text)>") { (_) in
                let tuple = graph.children[0]
                XCTAssertTrue(tuple.anyView is TupleView<(Text, Text, Text)>)
                XCTAssertEqual(tuple.children.count, 3)
                XCTAssertFalse(tuple.isRoot)
                XCTAssertFalse(tuple.isUserDefinedView)
                XCTAssertFalse(tuple.isModifiedContent)
                XCTAssertEqual(tuple.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
                XCTAssertEqual(tuple.listType, .vertical)
                XCTAssertEqual(tuple.spacing, spacing)
                
                XCTContext.runActivity(named: "check TupleView children view") { (_) in
                    graph.children.map { $0 }[0].children.forEach { child in
                        XCTAssertTrue(child.anyView is Text)
                        XCTAssertTrue(child.children.isEmpty)
                        XCTAssertEqual(child.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
                        XCTAssertFalse(child.isRoot)
                        XCTAssertFalse(child.isUserDefinedView)
                        XCTAssertFalse(child.isModifiedContent)
                    }
                }
            }
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let horizontalAlignment: HorizontalAlignment = .leading
            let spacing: PhysicalDistance = PhysicalDistance(100)
            let view = VStack(alignment: horizontalAlignment, spacing: spacing) {
                Text("1")
                Text("23")
                Text("456")
                    .alignmentGuide(.leading, computeValue: { _ in 10 })
            }
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is VStack<TupleView<(Text, Text, ModifiedContent<Text, _AlignmentWritingModifier>)>>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertFalse(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
            
            XCTAssertEqual(graph.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
            XCTAssertEqual(graph.listType, .vertical)
            XCTAssertEqual(graph.spacing, spacing)
            
            XCTContext.runActivity(named: "And check children view of TupleView<(Text, Text, ModifiedContent<Text, _AlignmentWritingModifier>)>") { (_) in
                let tuple = graph.children[0]
                XCTAssertTrue(tuple.anyView is TupleView<(Text, Text, ModifiedContent<Text, _AlignmentWritingModifier>)>)
                XCTAssertEqual(tuple.children.count, 3)
                XCTAssertFalse(tuple.isRoot)
                XCTAssertFalse(tuple.isUserDefinedView)
                XCTAssertFalse(tuple.isModifiedContent)
                XCTAssertEqual(tuple.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
                XCTAssertEqual(tuple.listType, .vertical)
                XCTAssertEqual(tuple.spacing, spacing)
                
                XCTContext.runActivity(named: "check TupleView children view") { (_) in
                    first: do {
                        let text = tuple.children[0]
                        XCTAssertTrue(text.anyView is Text)
                        XCTAssertTrue(text.children.isEmpty)
                        XCTAssertEqual(text.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
                        XCTAssertFalse(text.isRoot)
                        XCTAssertFalse(text.isUserDefinedView)
                        XCTAssertFalse(text.isModifiedContent)
                    }
                    second: do {
                        let text = tuple.children[1]
                        XCTAssertTrue(text.anyView is Text)
                        XCTAssertTrue(text.children.isEmpty)
                        XCTAssertEqual(text.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
                        XCTAssertFalse(text.isRoot)
                        XCTAssertFalse(text.isUserDefinedView)
                        XCTAssertFalse(text.isModifiedContent)
                    }
                    second: do {
                        let modifierGraph = tuple.children[2]
                        let alignmentModifier = modifierGraph.anyView as! HasAnyModifier
                        XCTAssertTrue(alignmentModifier.anyModifier is _AlignmentWritingModifier)

                        let text = modifierGraph.children[0]
                        XCTAssertTrue(text.anyView is Text)
                        XCTAssertTrue(text.children.isEmpty)
                        XCTAssertEqual(text.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
                        XCTAssertFalse(text.isRoot)
                        XCTAssertFalse(text.isUserDefinedView)
                        XCTAssertFalse(text.isModifiedContent)
                    }
                }
            }
        }
        XCTContext.runActivity(named: "when CustomView has Text") { (_) in
            let view = CustomView(body: Text("123"))
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is CustomView<Text>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertTrue(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)

            XCTContext.runActivity(named: "And check children view of Text") { (_) in
                graph.children.forEach { child in
                    XCTAssertTrue(child.anyView is Text)
                    XCTAssertTrue(child.children.isEmpty)
                    XCTAssertFalse(child.isRoot)
                    XCTAssertFalse(child.isUserDefinedView)
                    XCTAssertFalse(child.isModifiedContent)
                }
            }
        }
        XCTContext.runActivity(named: "when CustomView has VStack<Text>") { (_) in
            let view = CustomView(body: VStack { Text("123") })
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is CustomView<VStack<Text>>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertTrue(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
            
            XCTContext.runActivity(named: "And check children view of VStack<Text>") { (_) in
                graph.children.forEach { child in
                    XCTAssertTrue(child.anyView is VStack<Text>)
                    XCTAssertEqual(child.children.count, 1)
                    XCTAssertFalse(child.isRoot)
                    XCTAssertFalse(child.isUserDefinedView)
                    XCTAssertFalse(child.isModifiedContent)
                }
            }
        }
        XCTContext.runActivity(named: "when CustomView has VStack<TupleView<Text, Text, Text>>") { (_) in
            let horizontalAlignment: HorizontalAlignment = .leading
            let spacing: PhysicalDistance = PhysicalDistance(100)
            let view = CustomView(body: VStack(alignment: horizontalAlignment, spacing: spacing) {
                Text("123")
                Text("456")
                Text("789")
            })
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is CustomView<VStack<TupleView<(Text, Text, Text)>>>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertTrue(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
            
            XCTContext.runActivity(named: "And check children view of VStack<TupleView<Text, Text, Text>>") { (_) in
                graph.children.forEach { child in
                    XCTAssertTrue(child.anyView is VStack<TupleView<(Text, Text, Text)>>)
                    XCTAssertEqual(child.children.count, 1)
                    XCTAssertFalse(child.isRoot)
                    XCTAssertFalse(child.isUserDefinedView)
                    XCTAssertFalse(child.isModifiedContent)
                    
                }
                XCTContext.runActivity(named: "And check VStack children view of TupleView<Text, Text, Text>") { (_) in
                    graph.children.map { $0 }[0].children.forEach { child in
                        XCTAssertTrue(child.anyView is TupleView<(Text, Text, Text)>)
                        XCTAssertEqual(child.children.count, 3)
                        XCTAssertFalse(child.isRoot)
                        XCTAssertFalse(child.isUserDefinedView)
                        XCTAssertFalse(child.isModifiedContent)
                        
                        XCTAssertEqual(child.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
                        XCTAssertEqual(child.listType, .vertical)
                        XCTAssertEqual(child.spacing, spacing)
                    }
                }
            }
        }
        XCTContext.runActivity(named: "when CustomView has VStack<TupleView<CustomView<Text>, CustomView<Text>>>") { (_) in
            let view = CustomView(body: VStack {
                CustomView(body: Text("123"))
                CustomView(body: Text("456"))
            })
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is CustomView<VStack<TupleView<(CustomView<Text>, CustomView<Text>)>>>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertTrue(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
            
            XCTContext.runActivity(named: "And check VStack<TupleView<(CustomView<Text>, CustomView<Text>)>> children view of TupleView<(CustomView<Text>, CustomView<Text>)>") { (_) in
                let vStackGraph = graph.children.map { $0 }[0]
                vStackGraph.children.forEach { child in
                    XCTAssertTrue(child.anyView is TupleView<(CustomView<Text>, CustomView<Text>)>)
                    XCTAssertEqual(child.children.count, 2)
                    XCTAssertFalse(child.isRoot)
                    XCTAssertFalse(child.isUserDefinedView)
                    XCTAssertFalse(child.isModifiedContent)
                    
                    XCTContext.runActivity(named: "And check TupleVeiw children view") { (_) in
                        let tupleViewGraph = vStackGraph.children.map { $0 }[0]
                        tupleViewGraph.children.forEach { child in
                            XCTAssertTrue(child.anyView is CustomView<Text>)
                            XCTAssertEqual(child.children.count, 1)
                            XCTAssertTrue(child.children.map { $0 }[0].anyView is Text)
                            XCTAssertFalse(child.isRoot)
                            XCTAssertTrue(child.isUserDefinedView)
                            XCTAssertFalse(child.isModifiedContent)
                        }
                    }
                }
            }
            
            XCTContext.runActivity(named: "when Text with Modifier for _BackgroundModifier<Text>. _BackgroundModifier is not modifed size") { (_) in
                let view = Text("123").background(Color.red)
                let visitor = ViewGraphSetVisitor()
                let graph = visitor.visit(view)
                
                XCTAssertTrue(graph.anyView is ModifiedContent<Text, _BackgroundModifier<Color>>)
                XCTAssertEqual(graph.children.count, 1)
                XCTAssertTrue(graph.isRoot)
                XCTAssertFalse(graph.isUserDefinedView)
                XCTAssertTrue(graph.isModifiedContent)
                
                XCTContext.runActivity(named: "And check children view of Text") { (_) in
                    graph.children.forEach { child in
                        XCTAssertTrue(child.anyView is Text)
                        XCTAssertTrue(child.children.isEmpty)
                        XCTAssertFalse(child.isRoot)
                        XCTAssertFalse(child.isUserDefinedView)
                        XCTAssertFalse(child.isModifiedContent)
                    }
                }
            }
            
            XCTContext.runActivity(named: "when Original Modifier") { (_) in
                struct Modifier: ViewModifier {
                    func body(content: Content) -> some View {
                        content.background(Color.red)
                    }
                }
                let view = Text("1").modifier(Modifier())
                let visitor = ViewGraphSetVisitor()
                let graph = visitor.visit(view)
                
                XCTAssertTrue(graph.anyView is ModifiedContent<Text, Modifier>)
                XCTAssertEqual(graph.children.count, 1)
                XCTAssertTrue(graph.isRoot)
                XCTAssertFalse(graph.isUserDefinedView)
                XCTAssertTrue(graph.isModifiedContent)
                
                XCTContext.runActivity(named: "And check children view of Text") { (_) in
                    graph.children.forEach { child in
                        XCTAssertTrue(child.anyView is Text)
                        XCTAssertTrue(child.children.isEmpty)
                        XCTAssertFalse(child.isRoot)
                        XCTAssertFalse(child.isUserDefinedView)
                        XCTAssertFalse(child.isModifiedContent)
                    }
                }
            }
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
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is VStack<TupleView<(ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>, Text, Text)>>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertFalse(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
            
            XCTContext.runActivity(named: "And check children view of AlignmentWriteModifier relations") { (_) in
                let tupleView = graph.children[0]
                XCTAssertTrue(tupleView.anyView is TupleView<(ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>, Text, Text)>)
                
                let modifier = tupleView.children[0]
                XCTAssertTrue(modifier.anyView is ModifiedContent<ModifiedContent<Text, _AlignmentWritingModifier>, _AlignmentWritingModifier>)
                
                let childModifier = modifier.children[0]
                XCTAssertTrue(childModifier.anyView is ModifiedContent<Text, _AlignmentWritingModifier>)
                
                let text = childModifier.children[0]
                XCTAssertTrue(text.anyView is Text)
            }
        }
        XCTContext.runActivity(named: "when CustomView has EmptyView") { (_) in
            let view = CustomView(body: EmptyView())
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is CustomView<EmptyView>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertTrue(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
            
            XCTContext.runActivity(named: "And check children view of EmptyView") { (_) in
                graph.children.forEach { child in
                    XCTAssertTrue(child.anyView is EmptyView)
                    XCTAssertTrue(child.children.isEmpty)
                    XCTAssertFalse(child.isRoot)
                    XCTAssertFalse(child.isUserDefinedView)
                    XCTAssertFalse(child.isModifiedContent)
                }
            }
        }
        
        XCTContext.runActivity(named: "when Text with _PaddingLayut") { _ in
            let view = Text("123").padding()
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view)
            
            XCTAssertTrue(graph.anyView is ModifiedContent<Text, _PaddingLayout>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertFalse(graph.isUserDefinedView)
            XCTAssertTrue(graph.isModifiedContent)
            
            XCTContext.runActivity(named: "And check children view of Text") { (_) in
                graph.children.forEach { child in
                    XCTAssertTrue(child.anyView is Text)
                    XCTAssertTrue(child.children.isEmpty)
                    XCTAssertFalse(child.isRoot)
                    XCTAssertFalse(child.isUserDefinedView)
                    XCTAssertFalse(child.isModifiedContent)
                }
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
