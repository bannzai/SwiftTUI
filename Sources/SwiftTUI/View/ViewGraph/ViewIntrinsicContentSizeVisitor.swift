//
//  ViewIntrinsicContentSizeVisitor.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

internal protocol ViewIntrinsicContentSizeAcceptable {
    func accept(visitor: ViewIntrinsicContentSizeVisitor) -> ViewIntrinsicContentSizeVisitor.VisitResult
}

internal final class ViewIntrinsicContentSizeVisitor: Visitor {
    internal typealias VisitResult = Size
    internal init() { }
    
    internal func visit<T: View>(_ content: T) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let acceptable as ViewIntrinsicContentSizeAcceptable:
            return acceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
