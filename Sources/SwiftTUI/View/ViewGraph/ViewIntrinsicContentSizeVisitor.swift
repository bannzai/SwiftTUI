//
//  ViewSetRectVisitor.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/01/02.
//

import Foundation

internal protocol ViewIntrinsicContentSizeAcceptable {
    func accept(visitor: ViewSetRectVisitor) -> ViewSetRectVisitor.VisitResult
}

internal final class ViewSetRectVisitor: Visitor {
    internal typealias VisitResult = Void
    internal init() { }
    
    internal var proposedSize: Size = .zero
//    internal var dimensions: ViewDimensions = .init()
    internal var currentContainerGraph: ViewGraph?

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
