//
//  DummyScreen.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/11.
//

import XCTest
@testable import SwiftTUI

class DummyScreen: Screen {
    override var columns: PhysicalDistance { 100 }
    override var rows: PhysicalDistance { 100 }
}

