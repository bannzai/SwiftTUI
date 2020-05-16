//
//  ViewVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/09.
//

import Foundation

internal enum ViewVisitorListOption {
    internal static let `default`: ViewVisitorListOption = .vertical
    case vertical
    case horizontal

    internal var defaultSpace: PhysicalDistance {
        switch self {
        case .vertical:
            return 0
        case .horizontal:
            return 0
        }
    }
}


internal protocol ViewContentAcceptable {
    func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult
}

internal final class ViewContentVisitor: Visitor {
    internal typealias VisitResult = Void
    internal var driver: DrawableDriver
    internal var current: ViewGraph?
    
    internal init(driver: DrawableDriver) {
        self.driver = driver
    }
    
    internal func visit<T: View>(_ content: T) -> VisitResult {
        debugLogger.debug(userInfo: "begin content visitor: \(type(of: content))")
        defer {
            debugLogger.debug(userInfo: "end content visitor: \(type(of: content))")
        }
        switch content {
        case let viewAcceptable as ViewContentAcceptable:
            return viewAcceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
