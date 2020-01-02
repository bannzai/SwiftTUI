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
extension EmptyView: _ViewSizeAcceptable {
    internal func accept(visitor: _ViewSizeVisitor, with argument: _ViewSizeVisitor.Argument) -> _ViewSizeVisitor.VisitResult {
        return .zero
    }
}
