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
    class TestVisitor: Visitor {
        var called = false
        func visit<T>(_ content: T) -> Void {
            if let _ = content as? Acceptable {
                called = true
            }
        }
    }
    
    struct CustomView: View {
        var body: some View {
            Text("")
        }
    }
    
    // NOTE: `View` should confirm to Acceptable and called accept(visitor:) via Visitor.visit
    func testProtoocls() {
        let views: [Acceptable] = [
            TupleView((Text(""), Text(""))),
            Group { Text("") },
            TupleView(Text("")),
            Text(""),
            EmptyView(),
            AnyView(EmptyView()),
            CustomView(),
        ]

        views.enumerated().forEach { (offset, view) in
            print("test execute for \(type(of: view))")
            XCTContext.runActivity(named: "when \(type(of: view))") { _ in
                let visitor = TestVisitor()
                _ = visitor.visit(view)
                XCTAssertTrue(visitor.called)
            }
        }
    }
}
