//
//  VisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import XCTest
@testable import SwiftTUI

class VisitorTests: XCTestCase {
    class TestVisitor: Visitor {
        var called = false
        override func visit<T>(_ element: T) {
            if let _ = element as? AnyViewWrappable {
                called = true
                return
            }
        }
    }
    
    func testCheck_ConfirmAnyViewWrappable() {
        let views: [Acceptable] = [
            Group { Text("") },
            TupleView(Text("")),
            TupleView((Text(""), Text(""))),
            Text(""),
            EmptyView(),
            AnyView(EmptyView()),
        ]
        

        views.enumerated().forEach { (offset, view) in
            XCTContext.runActivity(named: "when \(type(of: view))") { _ in
                let visitor = TestVisitor()
                view.accept(visitor: visitor)
                XCTAssertTrue(visitor.called)
            }
        }
    }
}
