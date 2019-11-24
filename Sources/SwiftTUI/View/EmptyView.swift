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
}

extension EmptyView: Acceptable {
    public func _typeOf() -> _AcceptableType {
        .single(.empty)
    }
    public func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
        ""
    }
}
