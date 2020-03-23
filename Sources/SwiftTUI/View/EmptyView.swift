//
//  EmptyView.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

@frozen public struct EmptyView {
    @inlinable public init() { }
}

extension EmptyView : View {
    public typealias Body = Never
}

extension EmptyView: ViewContentAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        
    }
}

extension EmptyView: Primitive { }
extension EmptyView: ViewGraphSetAcceptable {
    public func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        _accept(visitor: visitor)
    }
}
