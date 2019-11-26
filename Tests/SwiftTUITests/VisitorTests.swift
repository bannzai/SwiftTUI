//
//  VisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import XCTest
import Foundation
import Runtime
@testable import SwiftTUI

@available(OSX 10.15.0, *)
class VisitorTests: XCTestCase {
    struct CustomView: View {
        var body: some View {
            EmptyView()
        }
    }

    func testViewVisitor() {
        XCTContext.runActivity(named: "when CustomView") { (_) in
            let view = CustomView()
            let visitor = ViewVisitor()
            let result = visitor.visit(view)
            XCTAssertEqual(result, "")
        }
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let visitor = ViewVisitor()
            let result = visitor.visit(view)
            XCTAssertEqual("hoge", result)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("2")
                Text("3")
            }
            let visitor = ViewVisitor()
            let result = visitor.visit(view)
            XCTAssertEqual("1\n2\n3\n", result)
        }
    }
}
