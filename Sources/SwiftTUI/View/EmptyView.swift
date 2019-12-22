//
//  EmptyView.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

public struct EmptyView {
    @inlinable public init() { }
}

extension EmptyView : View {
    public typealias Body = Never
    public var _baseProperty: _ViewBaseProperties? {
        _ViewBaseProperties()
    }
}

extension EmptyView: ViewAcceptable {
    public func accept<V: ViewContentVisitor>(visitor: V) -> V.VisitResult {
        
    }
}
