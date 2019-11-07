//
//  TupleView.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

/// A View created from a swift tuple of View values.
public struct TupleView<T> {
    public var value: T

    @inlinable public init(_ value: T) {
        self.value = value
    }
}

extension TupleView: View {
    public typealias Body = Never
}

public extension TupleView {
    func accept<VisitorType: Visitor>(visitor: VisitorType) {
        fatalError("Unexpected visitor type \(visitor) when T of \(type(of: T.self))")
    }
    
    func accept<VisitorType: Visitor, C0: View, C1: View>(visitor: VisitorType) where T == (C0, C1) {
        visitor.visit(value.0)
        visitor.visit(value.1)
    }
}
