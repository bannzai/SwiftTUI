//
//  ViewVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2019/11/24.
//

import XCTest
@testable import SwiftTUI

@available(OSX 10.15.0, *)
class ViewVisitorTests: XCTestCase {
    class TestVisitor: AnyViewVisitor {
        var called: Bool = false
        override func visit<T>(_ content: T) -> AnyViewVisitor.VisitResult where T : View {
            called = true
            return ""
        }
    }
    func testAcceptablesAllowViewVisitor() {
        _AcceptableType.Single.allCases.forEach { type in
            XCTContext.runActivity(named: "when \(type)") { (activity) in
                switch type {
                case .never, .anyStorageBase:
                    print("Skip \(#function), for \(type)")
                case _:
                    let visitor = TestVisitor()
                    _ = type.testVisit(visitor: visitor)
                    XCTAssertTrue(visitor.called)
                }
            }
        }
    }
}

let dummyAcceptableType: _AcceptableType = .single(.never)
@available(OSX 10.15.0, *)
extension _AcceptableType.Single {
    struct DummyView: View {
        typealias Body = Never
        func _typeOf() -> _AcceptableType { dummyAcceptableType }
        func accept<V>(visitor: V) -> AnyViewVisitor.VisitResult where V : AnyViewVisitor {
            return "\(DummyView.self)"
        }
    }
    struct Dummy_VariadicView_Root: _VariadicView_Root {
        
    }
    struct WrapperView: View {
        func _typeOf() -> _AcceptableType {
            dummyAcceptableType
        }
        
        let content: Acceptable
        func accept<V>(visitor: V) -> AnyViewVisitor.VisitResult where V : AnyViewVisitor {
            content.accept(visitor: visitor)
        }
        func accept<V>(visitor: V) -> AnyListViewVisitor.VisitResult where V : AnyListViewVisitor {
            content.accept(visitor: visitor)
        }
    }
    func testVisit(visitor: AnyViewVisitor) -> AnyViewVisitor.VisitResult {
        switch self {
        case .never:
            fatalError()
        case .any:
            return AnyView(DummyView()).accept(visitor: visitor)
        case .anyStorageBase:
            // NOTE: Check via `AnyView`
//            return AnyViewStorageBase().accept(visitor: visitor)
            fatalError()
        case .group:
            return Group { DummyView() }.accept(visitor: visitor)
        case .color:
            return Color.default.accept(visitor: visitor)
        case .empty:
            return EmptyView().accept(visitor: visitor)
        case .font:
            return Font().accept(visitor: visitor)
        case .text:
            return Text("").accept(visitor: visitor)
        case .tuple:
            return TupleView(DummyView()).accept(visitor: visitor)
            
        case .conditionalContent:
            return ViewBuilder._ConditionalContent<DummyView, DummyView>(storage: .truthy(DummyView())).accept(visitor: visitor)
        case .variadicViewTree:
            return WrapperView(content: VariadicView.Tree(root: Dummy_VariadicView_Root(), content: DummyView())).accept(visitor: visitor)
        }
    }
}
