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
        // TODO: alignmentやlisttypeのテスト？
        
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("123")
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view: view)
            
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
            let graph = visitor.visit(view: view)
            
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
            let graph = visitor.visit(view: view)
            
            XCTAssertTrue(graph.anyView is VStack<TupleView<(Text, Text, Text)>>)
            XCTAssertEqual(graph.children.count, 1)
            XCTAssertTrue(graph.isRoot)
            XCTAssertFalse(graph.isUserDefinedView)
            XCTAssertFalse(graph.isModifiedContent)
            
            XCTAssertEqual(graph.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
            XCTAssertEqual(graph.listType, .vertical)
            XCTAssertEqual(graph.spacing, spacing)
            
            XCTContext.runActivity(named: "And check children view of TupleView<(Text, Text, Text)>") { (_) in
                graph.children.forEach { child in
                    XCTAssertTrue(child.anyView is TupleView<(Text, Text, Text)>)
                    XCTAssertEqual(child.children.count, 3)
                    XCTAssertFalse(child.isRoot)
                    XCTAssertFalse(child.isUserDefinedView)
                    XCTAssertFalse(child.isModifiedContent)
                    
                    XCTAssertEqual(child.alignment, Alignment(horizontal: horizontalAlignment, vertical: .default))
                    XCTAssertEqual(child.listType, .vertical)
                    XCTAssertEqual(child.spacing, spacing)
                }
                XCTContext.runActivity(named: "check TupleView children view") { (_) in
                    graph.children.map { $0 }[0].children.forEach { child in
                        XCTAssertTrue(child.anyView is Text)
                        XCTAssertTrue(child.children.isEmpty)
                        XCTAssertFalse(child.isRoot)
                        XCTAssertFalse(child.isUserDefinedView)
                        XCTAssertFalse(child.isModifiedContent)
                    }
                }
            }
        }
        XCTContext.runActivity(named: "when CustomView has Text") { (_) in
            let view = CustomView(body: Text("123"))
            let visitor = ViewGraphSetVisitor()
            let graph = visitor.visit(view: view)
            
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
            let graph = visitor.visit(view: view)
            
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
            let graph = visitor.visit(view: view)
            
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
            let graph = visitor.visit(view: view)
            
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
                let graph = visitor.visit(view: view)
                
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
                let graph = visitor.visit(view: view)
                
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
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
