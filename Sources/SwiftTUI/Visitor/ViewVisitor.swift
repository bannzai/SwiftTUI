//
//  ViewVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/09.
//

import Foundation

// TOOD: Internal
open class AnyViewVisitor: Visitor {
    public typealias VisitResult = SwiftTUIContentType
    
    open func visit<T>(_ content: T) -> VisitResult {
        fatalError("Should override this method to subclass")
    }
}

public class ViewVisitor: AnyViewVisitor {
    public override func visit<T: View>(_ content: T) -> VisitResult {
        content.accept(visitor: self)
    }
}
