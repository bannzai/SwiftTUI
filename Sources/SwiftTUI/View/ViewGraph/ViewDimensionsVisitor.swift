//
//  ViewDimensionsVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/01/09.
//

import Foundation

internal protocol ViewDimensionsAcceptable {
    func accept(visitor: ViewDimensionsVisitor) -> ViewDimensionsVisitor.VisitResult
}

internal final class ViewDimensionsVisitor: Visitor {
    internal typealias VisitResult = ViewDimensions
    internal init() { }
    
    internal var current: ViewDimensions?

    internal func visit<T: View>(_ content: T) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let acceptable as ViewDimensionsAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
