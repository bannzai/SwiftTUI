//
//  Driver.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/11.
//

import XCTest
@testable import SwiftTUI

final class Driver: DrawableDriver {
    var callBag: [StaticString] = []
    var storedRunes: [Rune] = []
    var storedString: String {
        storedRunes.compactMap(Unicode.Scalar.init)
            .compactMap(Character.init)
            .compactMap(String.init)
            .joined()
    }
    func add(rune: Rune) {
        callBag.append(#function)
        storedRunes.append(rune)
    }
    
    var storedForegroundColors: [Color] = []
    func setForegroundColor(_ color: Color) {
        callBag.append(#function)
        storedForegroundColors.append(color)
    }
    
    var storedBackgroundColors: [Color] = []
    func setBackgroundColor(_ color: Color) {
        callBag.append(#function)
        storedBackgroundColors.append(color)
    }
    
    var keepForegroundColor: Color?
    var keepBackgroundColor: Color?
    
    func content() -> String {
        callBag.append(#function)
        return storedRunes.compactMap(Unicode.Scalar.init)
            .map(Character.init)
            .map(String.init)
            .reduce("", +)
    }
    
    func clear() {
        storedRunes.removeAll()
    }
    
}
