//
//  ViewVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/09.
//

import Foundation

public enum ViewVisitorListOption {
    static let `default`: ViewVisitorListOption = .horizontal
    case vertical
    case horizontal
    
    var defaultSpace: PhysicalDistance {
        switch self {
        case .vertical:
            return 2
        case .horizontal:
            return 2
        }
    }
}

internal protocol ViewContentAcceptable {
    func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult
}

internal protocol ContainerViewContentAcceptable {
    
}

internal final class ViewContentVisitor: Visitor {
    internal typealias VisitResult = Void
    internal let driver: DrawableDriver
    internal init(driver: DrawableDriver) {
        self.driver = driver
    }
    
    internal var containerAlignment: Alignment = .default

    internal func visit<T: View>(_ content: T, with listOptions: ViewVisitorListOption) -> VisitResult {
        debugLogger.debug()
        switch content {
        case let viewAcceptable as ViewContentAcceptable:
            return viewAcceptable.accept(visitor: self)
        case _:
            return visit(content.body, with: listOptions)
        }
    }
    internal func visit<T: View>(_ content: T) -> VisitResult {
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
