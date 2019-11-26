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
    class TestVisitor: AnyViewVisitor {
        override func visit<T: View>(_ content: T) -> SwiftTUIContentType {
            if let content = content as? Text {
                return visit(content)
            }
            if let content = content as? EmptyView {
                return visit(content)
            }
            return visit(content.body)
        }
        func visit(_ content: Text) -> SwiftTUIContentType { content.accept(visitor: self) }
        func visit(_ content: EmptyView) -> SwiftTUIContentType { content.accept(visitor: self) }
        func visit<T: View>(_ content: Group<T>) -> SwiftTUIContentType { content.accept(visitor: self) }
    }
    
    struct CustomView: View {
        var body: some View {
            EmptyView()
        }
    }

    func testViewVisitor() {
        XCTContext.runActivity(named: "when CustomView") { (_) in
            let view = CustomView()
            let visitor = TestVisitor()
            let result = visitor.visit(view)
            XCTAssertEqual(result, "")
        }
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let visitor = TestVisitor()
            let result = visitor.visit(view)
            XCTAssertEqual("hoge", result)
        }
    }
}
