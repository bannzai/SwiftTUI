//
//  Acceptable.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

// TODO: to internal type
public protocol Acceptable {
    func accept(visitor: Visitor)
}