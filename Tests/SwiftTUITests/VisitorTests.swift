//
//  VisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import XCTest
import Foundation
@testable import SwiftTUI

@available(OSX 10.15.0, *)
class VisitorTests: XCTestCase {
    class TestVisitor: AnyViewVisitor {
        var called = false
        override func visit<T: View>(_ content: T) -> SwiftTUIContentType { content.accept(visitor: self) }
        func visit(_ content: Text) -> SwiftTUIContentType { content.accept(visitor: self) }
    }
    
    struct CustomView: View, Acceptable {
        var body: some View {
            EmptyView()
        }
        
        public func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
            (visitor as? TestVisitor)?.called = true
            return ""
        }
        public func accept<V: AnyListViewVisitor>(visitor: V) -> V.VisitResult {
            fatalError()
        }
    }

    func testViewVisitor() {
//        XCTContext.runActivity(named: "when custom view") { (_) in
//            let view = CustomView()
//            let visitor = TestVisitor()
//            _ = visitor.visit(view)
//            XCTAssertTrue(visitor.called)
//        }
        XCTContext.runActivity(named: "when text") { (_) in
            let view = Text("hoge")
            let visitor = TestVisitor()
            let result = visitor.visit(view)
            XCTAssertEqual("hoge", result)
        }
    }
}
