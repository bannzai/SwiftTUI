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

internal protocol ContainerViewContentAcceptable {
    
}

internal final class ViewContentVisitor: Visitor {
    internal typealias VisitResult = Void
    internal var driver: DrawableDriver
    internal init(driver: DrawableDriver) {
        self.driver = driver
    }
    
    internal func visit<T: View>(_ content: T) -> VisitResult {
        switch content {
        case let viewAcceptable as ViewContentAcceptable:
            return viewAcceptable.accept(visitor: self)
        case _:
            return visit(content.body)
        }
    }
}
