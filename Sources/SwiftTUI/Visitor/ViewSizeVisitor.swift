//
//  SizeVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/29.
//

import Foundation

internal protocol ViewSizeAcceptable {
    func accept(visitor: ViewSizeVisitor) -> ViewSizeVisitor.VisitResult
}

internal protocol ContainerViewSizeAcceptable: ViewSizeAcceptable {
    func accept(visitor: ViewSizeVisitor, with listOption: ViewVisitorListOption) -> ViewSizeVisitor.VisitResult
}

internal final class ViewSizeVisitor: Visitor {
    internal typealias VisitResult = Rect
    internal var currentRect: Rect
    internal init(rect: Rect) {
        currentRect = rect
    }

    internal func visit<T: View>(_ content: T) -> VisitResult {
        fatalError("// TODO:")
    }
}
