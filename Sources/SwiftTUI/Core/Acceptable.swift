//
//  ViewAcceptable.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/26.
//

import Foundation

public protocol ViewAcceptable {
    func accept<V: ViewContentVisitor>(visitor: V) -> V.VisitResult
}

public protocol ContainerViewAcceptable: ViewAcceptable {
    func accept<V: ViewContentVisitor>(visitor: V, with listOption: ViewVisitorListOption) -> V.VisitResult
}
