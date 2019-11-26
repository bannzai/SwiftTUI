//
//  Acceptable.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/26.
//

import Foundation

public protocol ViewAcceptable {
    func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult
}

public typealias Acceptable = ViewAcceptable
