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
    internal func visit<T: View>(_ content: T, with listOptions: ViewVisitorListOption) -> VisitResult {
        fatalError("Should override this method to subclass")
    }
    internal func appliedAttribute<V: View>(view: V, content: SwiftTUIContentType) -> VisitResult {
        var content = content
        if let backgroundColor = view._baseProperty?.backgroundColor {
            content = Terminal.colorize(color: backgroundColor.backgroundColor, content: content)
        }
        return content
    }
}

public enum ViewVisitorListOption {
    static let `default`: ViewVisitorListOption = .horizontal
    case vertical
    case horizontal
}

public final class ViewVisitor: AnyViewVisitor {
    internal override func visit<T: View>(_ content: T, with listOptions: ViewVisitorListOption) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let viewAcceptableWithListOption as ViewAcceptableWithListOption:
            return viewAcceptableWithListOption.accept(visitor: self, with: listOptions)
        case let viewAcceptable as ViewAcceptable:
            let result = viewAcceptable.accept(visitor: self)
            return appliedAttribute(view: content, content: result)
        case _:
            return visit(content.body, with: listOptions)
        }
    }
    public override func visit<T: View>(_ content: T) -> VisitResult {
        visit(content, with: .default)
    }
}
