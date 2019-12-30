//
//  ViewContentVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import XCTest
import Foundation
import Runtime
@testable import SwiftTUI

class ViewContentVisitorTests: XCTestCase {
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
        
        var storedForegroundColors: [Color] = []
        func setForegroundColor(_ color: Color) {
            storedForegroundColors.append(color)
        }
        
        var storedBackgroundColors: [Color] = []
        func setBackgroundColor(_ color: Color) {
            storedBackgroundColors.append(color)
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
            
            XCTAssertEqual(result.filter { $0 == "\n" }.count, 3)
            XCTAssertTrue(result.contains("1"))
            XCTAssertTrue(result.contains("2"))
            XCTAssertTrue(result.contains("3"))
            
            XCTAssertTrue(driver.storedBackgroundColors.contains(.red))
            XCTAssertEqual(driver.storedBackgroundColors.last, Style.Color.background.color)
            XCTAssertTrue(driver.storedForegroundColors.contains(.blue))
            XCTAssertEqual(driver.storedForegroundColors.last, Style.Color.foreground.color)
        }
        XCTContext.runActivity(named: "when Original Modifier") { (_) in
            Terminal.isDisableColorize = false
            
            struct Modifier: ViewModifier {
                func body(content: Content) -> some View {
                    content.background(Color.red)
                }
            }
            
            let view = Text("1").modifier(Modifier())
            let driver = Driver()
            let visitor = ViewContentVisitor(driver: driver)
            visitor.visit(view)
            let result = driver.content()
            
            XCTAssertEqual("1", result)

            XCTAssertTrue(driver.storedBackgroundColors.contains(.red))
            XCTAssertEqual(driver.storedBackgroundColors.last, Style.Color.background.color)
        }
    }
}
