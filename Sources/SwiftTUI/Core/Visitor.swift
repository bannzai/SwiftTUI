//
//  Visitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

// TODO: to internal type
public protocol Visitor {
    // FIXME: Using more generics protocol. e.g) See also, deleted commit 0c202caafabc48ef3e18b01d65d046f58069423e
    associatedtype VisitResult = SwiftTUIContentType
    
    func visit<T>(_ content: T) -> VisitResult
}
