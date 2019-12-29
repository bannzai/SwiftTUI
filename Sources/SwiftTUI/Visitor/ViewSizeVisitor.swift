//
//  SizeVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/29.
//

import Foundation

public protocol ViewSizeAcceptable {
    func accept<V: ViewSizeVisitor>(visitor: V) -> V.VisitResult
}

public protocol ContainerViewSizeAcceptable: ViewSizeAcceptable {
    func accept<V: ViewSizeVisitor>(visitor: V, with listOption: ViewVisitorListOption) -> V.VisitResult
}

public final class ViewSizeVisitor: Visitor {
    public typealias VisitResult = Void

    public func visit<T>(_ content: T) -> Void where T : View {
        
    }
}
