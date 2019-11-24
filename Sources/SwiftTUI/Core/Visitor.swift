//
//  Visitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

// TODO: to internal type
public protocol Visitor {
    associatedtype VisitResult: Collector
    
    func visit<T>(_ content: T) -> VisitResult
}

public protocol ListVisitor {
    associatedtype VisitResult: Collector
    
    func visit<T>(_ content: T) -> [VisitResult]
}
