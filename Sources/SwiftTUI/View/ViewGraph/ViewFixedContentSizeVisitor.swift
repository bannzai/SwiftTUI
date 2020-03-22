//
//  ViewFixedContentSizeVisitor.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

internal protocol ViewFixedContentSizeAcceptable {
    func accept(visitor: ViewFixedContentSizeVisitor) -> ViewFixedContentSizeVisitor.VisitResult
}

internal final class ViewFixedContentSizeVisitor: Visitor {
    internal typealias VisitResult = Size
    internal init() { }
    
    internal func visit<T: View>(_ content: T) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let acceptable as ViewFixedContentSizeAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
