//
//  ViewVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/09.
//

import Foundation

// TODO: Internal
public enum ViewVisitorListOption {
    static let `default`: ViewVisitorListOption = .horizontal
    case vertical
    case horizontal
}

public final class ViewContentVisitor: Visitor {
    public typealias VisitResult = Void
    internal let driver: DrawableDriver
    internal init(driver: DrawableDriver) {
        self.driver = driver
    }
    
    internal var containerAlignment: Alignment = .default

    internal func visit<T: View>(_ content: T, with listOptions: ViewVisitorListOption) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let ContainerViewAcceptable as ContainerViewAcceptable:
            return ContainerViewAcceptable.accept(visitor: self, with: listOptions)
        case let viewAcceptable as ViewAcceptable:
            return viewAcceptable.accept(visitor: self)
        case _:
            return visit(content.body, with: listOptions)
        }
    }
    public func visit<T: View>(_ content: T) -> VisitResult {
        visit(content, with: .default)
    }
//    internal func appliedAttribute<V: View>(view: V, content: SwiftTUIContentType) -> VisitResult {
//        var content = content
//        if let backgroundColor = view._baseProperty?.backgroundColor {
//            content = Terminal.colorize(color: backgroundColor.backgroundColor, content: content)
//        }
//        if let border = view._baseProperty?.border {
//            // TODO: width, height + 1 and add content border character
//        }
//        return content
//    }
}
