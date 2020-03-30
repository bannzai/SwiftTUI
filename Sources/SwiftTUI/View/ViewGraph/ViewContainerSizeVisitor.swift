//
//  ViewContainerSizeVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/03/22.
//

import Foundation

internal protocol ViewContainerContentSizeAcceptable {
//    func accept(visitor: ViewContainerContentSizeVisitor) -> ViewContainerContentSizeVisitor.VisitResult
}

typealias ViewContainerContentSizeVisitor = ViewIntrinsicContentSizeVisitor
//internal final class ViewContainerContentSizeVisitor: Visitor {
//    internal typealias VisitResult = Void
//    internal init() { }
//
//    internal func visit<T: View>(_ content: T) -> VisitResult {
//        debugLogger.debug()
//        switch content {
//        case let acceptable as ViewContainerContentSizeAcceptable:
//            return acceptable.accept(visitor: self)
//        case _:
//            return visit(content.body)
//        }
//    }
//}
