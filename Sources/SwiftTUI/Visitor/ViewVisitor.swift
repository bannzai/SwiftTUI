//
//  ViewVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/09.
//

import Foundation

// TODO: Internal
open class AnyViewVisitor: Visitor {
    public typealias VisitResult = SwiftTUIContentType
    
    public init() {
        
    }
    open func visit<T: View>(_ content: T) -> VisitResult {
        fatalError("Should override this method to subclass")
    }
}

public class ViewVisitor: AnyViewVisitor {
    public override func visit<T: View>(_ content: T) -> VisitResult {
        guard let acceptable = content as? Acceptable else {
            return visit(content.body)
        }
        return acceptable.accept(visitor: self)
    }
}
