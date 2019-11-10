//
//  ViewVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/09.
//

import Foundation

// TOOD: Internal
open class TypeErasureVisitor: Visitor {
    public typealias VisitoResult = SwiftTUIContentType
    
    open func visit<T>(_ content: T) -> VisitoResult {
        fatalError("Should override this method to subclass")
    }
}

public class ViewVisitor: TypeErasureVisitor {
    public override func visit<T: View & Contentable>(_ content: T) -> VisitoResult {
        return content.content()
    }
}

public protocol TupleViewVisitor {
    associatedtype VisitResult

    func visit<T>(_ view: TupleView<T>) -> VisitResult
}

open class TypeErasureTupleViewVisitor: TupleViewVisitor {
    public typealias VisitResult = SwiftTUIContentType
    public func visit<T>(_ view: TupleView<T>) -> VisitResult {
        fatalError("Should override this method to subclass")
    }
}
