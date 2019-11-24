//
//  Acceptable.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

// TODO: to internal type
public protocol Acceptable {
    func _typeOf() -> _AcceptableType
    func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult
    func accept<V: AnyListViewVisitor>(visitor: V) -> V.VisitResult
}
