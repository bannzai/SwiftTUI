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
    internal typealias VisitResult = Void

    internal func visit<T>(_ content: T) -> Void where T : View {
        
    }
}
