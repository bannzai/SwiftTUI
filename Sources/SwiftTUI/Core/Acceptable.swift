//
//  Acceptable.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/26.
//

import Foundation

public protocol Acceptable {
    func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult
    func accept<V: AnyListViewVisitor>(visitor: V) -> V.VisitResult
}
