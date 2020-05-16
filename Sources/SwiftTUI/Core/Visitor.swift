//
//  Visitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

internal protocol Visitor {
    associatedtype VisitResult
    func visit<T: View>(_ content: T) -> VisitResult
}
