//
//  ViewSetRectVisitorTests.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/01/05.
//

import XCTest
@testable import SwiftTUI

class ViewSetRectVisitorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        mainScreen = DummyScreen.init()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testVisit() {
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
