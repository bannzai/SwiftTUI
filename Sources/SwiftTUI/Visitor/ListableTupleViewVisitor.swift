//
//  TupleViewVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/09.
//

import Foundation

open class ListableTupleViewVisitor: Visitor {
    public typealias VisitResult = [SwiftTUIContentType]
    public func visit<T>(_ content: T) -> [SwiftTUIContentType] {
        fatalError("Should override this method to subclass")
    }
}
