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

class VisitorTests: XCTestCase {
    struct CustomView: View {
        var body: some View {
            EmptyView()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        Terminal.isDisableColorize = true
    }

    func testViewContentVisitor {
        XCTContext.runActivity(named: "when CustomView") { (_) in
            let view = CustomView()
            let visitor = ViewContentVisitor
            let result = visitor.visit(view)
            XCTAssertEqual(result, "")
        }
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let visitor = ViewContentVisitor
            let result = visitor.visit(view)
            XCTAssertEqual("hoge", result)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("2")
                Text("3")
            }
            let visitor = ViewContentVisitor
            let result = visitor.visit(view)
            XCTAssertEqual("1\n2\n3\n", result)
        }
        XCTContext.runActivity(named: "when HStack contains TupleView<Text, Text, Text>") { (_) in
            let view = HStack {
                Text("1")
                Text("2")
                Text("3")
            }
            let visitor = ViewContentVisitor
            let result = visitor.visit(view)
            XCTAssertEqual("123", result)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, _BackgroundModifier<Text>>") { (_) in
            Terminal.isDisableColorize = false
            let view = VStack {
                Text("1")
                    .foregroundColor(.blue)
                Text("2")
                Text("3")
                    .background(Color.red)
            }
            let visitor = ViewContentVisitor
            let result = visitor.visit(view)
            
            print(result)
            XCTAssertEqual(result.filter { $0 == "\n" }.count, 3)
            XCTAssertTrue(result.contains("\(Color.blue.foregroundColor)"))
            XCTAssertTrue(result.contains("\(Color.red.backgroundColor)"))
        }
    }
}
