//
//  Visitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

// TODO: to internal type
public protocol Visitor {
    associatedtype VisitorResult
    
    func visit<T>(_ content: T) -> VisitorResult
}
