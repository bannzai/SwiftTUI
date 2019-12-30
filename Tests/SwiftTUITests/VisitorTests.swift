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
    
    class Driver: DrawableDriver {
        var storedRunes: [Rune] = []
        func add(rune: Rune) {
            storedRunes.append(rune)
        }
        
        func setForegroundColor(_ color: Color) {
            
        }
        
        func setBackgroundColor(_ color: Color) {
            
        }
        
        var keepForegroundColor: Color?
        var keepBackgroundColor: Color?
        
        func content() -> String {
            storedRunes.compactMap(Unicode.Scalar.init)
                .map(Character.init)
                .map(String.init)
                .reduce("", +)
        }
    }
    
    override func setUp() {
        super.setUp()
        
        Terminal.isDisableColorize = true
    }

    func testViewContentVisitor() {
        XCTContext.runActivity(named: "when CustomView") { (_) in
            let view = CustomView()
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            visitor.visit(view)
            let result = driver.content()
            XCTAssertEqual(result, "")
        }
        XCTContext.runActivity(named: "when Text with content") { (_) in
            let view = Text("hoge")
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            visitor.visit(view)
            let result = driver.content()
            XCTAssertEqual("hoge", result)
        }
        XCTContext.runActivity(named: "when VStack contains TupleView<Text, Text, Text>") { (_) in
            let view = VStack {
                Text("1")
                Text("2")
                Text("3")
            }
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            visitor.visit(view)
            let result = driver.content()
            XCTAssertEqual("1\n2\n3\n", result)
        }
        XCTContext.runActivity(named: "when HStack contains TupleView<Text, Text, Text>") { (_) in
            let view = HStack {
                Text("1")
                Text("2")
                Text("3")
            }
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            visitor.visit(view)
            let result = driver.content()
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
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            visitor.visit(view)
            let result = driver.content()

            print(result)
            XCTAssertEqual(result.filter { $0 == "\n" }.count, 3)
            XCTAssertTrue(result.contains("1"))
            XCTAssertTrue(result.contains("2"))
            XCTAssertTrue(result.contains("3"))
        }
    }
}
