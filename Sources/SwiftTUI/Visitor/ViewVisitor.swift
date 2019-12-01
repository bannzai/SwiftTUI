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
    open func visit<T: View>(_ content: T, with listOptions: ViewVisitorListOption) -> VisitResult {
        fatalError("Should override this method to subclass")
    }
}

public enum ViewVisitorListOption {
    static let `default`: ViewVisitorListOption = .horizontal
    case vertical
    case horizontal
}

public final class ViewVisitor: AnyViewVisitor {
    public override func visit<T: View>(_ content: T, with listOptions: ViewVisitorListOption) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let viewAcceptableWithListOption as ViewAcceptableWithListOption:
            return viewAcceptableWithListOption.accept(visitor: self, with: listOptions)
        case let viewAcceptable as ViewAcceptable:
            return viewAcceptable.accept(visitor: self)
        case _:
            return visit(content.body, with: listOptions)
        }
    }
    public override func visit<T: View>(_ content: T) -> VisitResult {
        visit(content, with: .default)
    }
}
