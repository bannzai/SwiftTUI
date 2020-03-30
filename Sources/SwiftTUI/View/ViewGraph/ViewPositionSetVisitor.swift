// 
//  ViewPositionSetVisitor.swift
//  Demo
//
//  Created by Yudai.Hirose on 2020/01/08.
//

import Foundation

internal protocol ViewPositionSetterAcceptable {
//    func accept(visitor: ViewPositionSetVisitor) -> ViewPositionSetVisitor.VisitResult
}

typealias ViewPositionSetVisitor = ViewSetRectVisitor
//internal final class ViewPositionSetVisitor: Visitor {
//    internal typealias VisitResult = Void
//    internal init() { }
//
//    internal func visit<T: View>(_ content: T) -> VisitResult {
//        debugLogger.debug()
//        switch content {
//        case let acceptable as ViewPositionSetterAcceptable:
//            return acceptable.accept(visitor: self)
//        case _:
//            return visit(content.body)
//        }
//    }
//}
